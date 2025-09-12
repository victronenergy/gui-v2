/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "alldevicesmodel.h"
#include "allservicesmodel.h"

#include <veutil/qt/ve_qitem.hpp>

#include <QQmlEngine>
#include <QQmlInfo>

using namespace Victron::VenusOS;

namespace {
bool includeServiceItem(VeQItem *serviceItem)
{
	// These are the services that we know do not represent devices. We could monitor them as device
	// candidates, but they would never be added to the device model as they do not have device
	// instances, so we might as well avoid monitoring them in the first place.
	static const QSet<QString> knownSystemServices = {
		QStringLiteral("adc"),
		QStringLiteral("ble"),
		QStringLiteral("digitalinputs"),
		QStringLiteral("hub4"),
		QStringLiteral("fronius"),
		QStringLiteral("logger"),
		QStringLiteral("modbusclient"),
		QStringLiteral("modem"),
		QStringLiteral("platform"),
		QStringLiteral("settings"),
		QStringLiteral("shelly"),
		QStringLiteral("system"),
		QStringLiteral("tailscale"),
		QStringLiteral("temprelay"),
	};
	return serviceItem
			&& !knownSystemServices.contains(BaseDevice::serviceTypeFromUid(serviceItem->uniqueId()));
}
}

AllDevicesModel::AllDevicesModel(QObject *parent)
	: QAbstractListModel(parent)
{
	AllServicesModel *allServicesModel = AllServicesModel::create();
	for (int i = 0; i < allServicesModel->count(); ++i) {
		VeQItem *serviceItem = allServicesModel->itemAt(i);
		if (includeServiceItem(serviceItem)) {
			Device *device = newDeviceCandidate(serviceItem);
			if (device->isValid()) {
				m_devices.append(device);
			}
		}
	}

	connect(allServicesModel, &AllServicesModel::serviceAdded,
			this, &AllDevicesModel::serviceAdded);
	connect(allServicesModel, &AllServicesModel::serviceAboutToBeRemoved,
			this, &AllDevicesModel::serviceAboutToBeRemoved);
	connect(allServicesModel, &AllServicesModel::modelAboutToBeReset,
			this, &AllDevicesModel::servicesAboutToBeReset);
	connect(allServicesModel, &AllServicesModel::modelReset,
			this, &AllDevicesModel::servicesReset);
}

AllDevicesModel::~AllDevicesModel()
{
	cleanUp();
}

void AllDevicesModel::serviceAdded(VeQItem *serviceItem)
{
	if (!includeServiceItem(serviceItem)) {
		return;
	}

	// When a new service is detected, monitor it and add it to the model if it is a device.
	Device *device = newDeviceCandidate(serviceItem);
	if (device->isValid()) {
		beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
		m_devices.append(device);
		endInsertRows();
		emit countChanged();
		emit deviceAdded(device);
	}
}

void AllDevicesModel::serviceAboutToBeRemoved(VeQItem *item)
{
	// When a service is removed from the system, stop monitoring it and remove it from the model.
	Device *device = m_allDeviceCandidates.take(item->uniqueId());
	device->disconnect(this);
	emit deviceAboutToBeRemoved(device);

	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices.at(i)->serviceItem() == item) {
			beginRemoveRows(QModelIndex(), i, i);
			m_devices.removeAt(i);
			endRemoveRows();
			emit countChanged();
			break;
		}
	}

	delete device;
}

void AllDevicesModel::servicesAboutToBeReset()
{
	beginResetModel();
	m_devices.clear();
	cleanUp();
}

void AllDevicesModel::servicesReset()
{
	AllServicesModel *allServicesModel = AllServicesModel::create();
	for (int i = 0; i < allServicesModel->count(); ++i) {
		VeQItem *serviceItem = allServicesModel->itemAt(i);
		if (includeServiceItem(serviceItem)) {
			Device *device = newDeviceCandidate(serviceItem);
			if (device->isValid()) {
				m_devices.append(device);
			}
		}
	}

	endResetModel();
	emit countChanged();
}

Device *AllDevicesModel::newDeviceCandidate(VeQItem *item)
{
	if (auto it = m_allDeviceCandidates.constFind(item->uniqueId()); it != m_allDeviceCandidates.constEnd()) {
		return it.value();
	}

	Device *device = new Device(this, item);
	m_allDeviceCandidates.insert(item->uniqueId(), device);
	connect(device, &BaseDevice::validChanged, this, &AllDevicesModel::deviceValidChanged);

	return device;
}

void AllDevicesModel::deviceValidChanged()
{
	Device *device = qobject_cast<Device *>(sender());
	if (!device) {
		return;
	}

	if (device->isValid()) {
		beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
		m_devices.append(device);
		endInsertRows();
		emit countChanged();
		emit deviceAdded(device);
	} else {
		if (const int deviceIndex = m_devices.indexOf(device); deviceIndex >= 0) {
			emit deviceAboutToBeRemoved(m_devices.at(deviceIndex));
			beginRemoveRows(QModelIndex(), deviceIndex, deviceIndex);
			m_devices.removeAt(deviceIndex);
			endRemoveRows();
			emit countChanged();
		}
	}
}

void AllDevicesModel::cleanUp()
{
	for (auto it = m_allDeviceCandidates.begin(); it != m_allDeviceCandidates.end(); ++it) {
		it.value()->disconnect(this);
		delete it.value();
	}
	m_allDeviceCandidates.clear();
}

int AllDevicesModel::count() const
{
	return m_devices.count();
}

QVariant AllDevicesModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_devices.count()) {
		return QVariant();
	}

	switch (role)
	{
	case DeviceRole:
		return QVariant::fromValue<Device *>(m_devices.at(row));
	default:
		return QVariant();
	}
}
int AllDevicesModel::rowCount(const QModelIndex &) const
{
	return count();
}

int AllDevicesModel::indexOf(const QString &uid) const
{
	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices.at(i) && m_devices.at(i)->serviceUid() == uid) {
			return i;
		}
	}
	return -1;
}

Device *AllDevicesModel::deviceAt(int index) const
{
	if (index >= 0 && index < m_devices.count()) {
		return m_devices.at(index);
	}
	return nullptr;
}

QHash<int, QByteArray> AllDevicesModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ DeviceRole, "device" },
	};
	return roles;
}

AllDevicesModel* AllDevicesModel::create(QQmlEngine *engine, QJSEngine *)
{
	static AllDevicesModel* instance = new AllDevicesModel(engine);
	return instance;
}
