/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "dcmeterdevicemodel.h"
#include "alldevicesmodel.h"
#include "enums.h"
#include "device.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

namespace {

int monitorModeForService(VeQItem *serviceItem)
{
	if (serviceItem) {
		if (VeQItem *monitorModeItem = serviceItem->itemGet(QStringLiteral("Settings/MonitorMode"))) {
			const QVariant monitorModeValue = monitorModeItem->getValue();
			if (monitorModeValue.isValid()) {
				bool ok = false;
				const int monitorModeInt = monitorModeValue.toInt(&ok);
				if (ok) {
					return monitorModeInt;
				}
			}
		}
	}
	return static_cast<int>(Enums::MonitorMode_Unknown);
}

}

void DcMeterDeviceModel::DcMeter::disconnect(DcMeterDeviceModel *model)
{
	if (powerItem) {
		powerItem->disconnect(model);
	}
	if (currentItem) {
		currentItem->disconnect(model);
	}
	if (monitorModeItem) {
		monitorModeItem->disconnect(model);
	}
}

DcMeterDeviceModel::DcMeterDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
}

DcMeterDeviceModel::~DcMeterDeviceModel()
{
	if (m_timerId > 0) {
		killTimer(m_timerId);
		m_timerId = 0;
	}
}

int DcMeterDeviceModel::count() const
{
	return m_meters.count();
}

Device *DcMeterDeviceModel::firstObject() const
{
	return deviceAt(0);
}

int DcMeterDeviceModel::firstMeterType() const
{
	return m_firstMeterType;
}

qreal DcMeterDeviceModel::totalPower() const
{
	return m_totalPower;
}

qreal DcMeterDeviceModel::totalCurrent() const
{
	return m_totalCurrent;
}

QStringList DcMeterDeviceModel::serviceTypes() const
{
	return m_serviceTypes;
}

void DcMeterDeviceModel::setServiceTypes(const QStringList &serviceTypes)
{
	if (m_serviceTypes != serviceTypes) {
		m_serviceTypes = serviceTypes;
		if (m_completed) {
			resetMeters();
		}
		emit serviceTypesChanged();
	}
}

int DcMeterDeviceModel::meterType() const
{
	return m_meterType;
}

void DcMeterDeviceModel::setMeterType(int meterType)
{
	if (m_meterType != meterType) {
		m_meterType = meterType;
		if (m_completed) {
			resetMeters();
		}
		emit meterTypeChanged();
	}
}

QVariant DcMeterDeviceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_meters.count()) {
		return QVariant();
	}

	switch (role)
	{
	case DeviceRole:
		return QVariant::fromValue<Device *>(m_meters.at(row).device);
	case MeterTypeRole:
		return m_meters.at(row).type;
	default:
		return QVariant();
	}
}

int DcMeterDeviceModel::rowCount(const QModelIndex &) const
{
	return count();
}

void DcMeterDeviceModel::classBegin()
{
}

void DcMeterDeviceModel::componentComplete()
{
	m_completed = true;
	resetMeters();

	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	connect(allDevicesModel, &AllDevicesModel::rowsInserted,
			this, &DcMeterDeviceModel::sourceDeviceAdded);
	connect(allDevicesModel, &AllDevicesModel::rowsAboutToBeRemoved,
			this, &DcMeterDeviceModel::sourceDeviceAboutToBeRemoved);

	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset, [this]() {
		beginResetModel();
		clearMeters();
	});
	connect(allDevicesModel, &AllDevicesModel::modelReset, [this]() {
		addMatchingMeters();
		endResetModel();
		emit countChanged();
	});
}

QHash<int, QByteArray> DcMeterDeviceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ DeviceRole, "device" },
		{ MeterTypeRole, "meterType" },
	};
	return roles;
}

Device *DcMeterDeviceModel::deviceAt(int index) const
{
	if (index >= 0 && index < m_meters.count()) {
		return m_meters.at(index).device;
	}
	return nullptr;
}

int DcMeterDeviceModel::meterTypeAt(int index)
{
	if (index >= 0 && index < m_meters.count()) {
		return m_meters.at(index).type;
	}
	return -1;
}

int DcMeterDeviceModel::indexOf(const QString &serviceUid) const
{
	for (int i = 0; i < m_meters.count(); ++i) {
		if (m_meters.at(i).device && m_meters.at(i).device->serviceUid() == serviceUid) {
			return i;
		}
	}
	return -1;
}

void DcMeterDeviceModel::resetMeters()
{
	beginResetModel();
	clearMeters();
	addMatchingMeters();
	endResetModel();
	emit countChanged();
}

void DcMeterDeviceModel::clearMeters()
{
	for (DcMeter &meter : m_meters) {
		meter.disconnect(this);
	}
	m_meters.clear();
}

void DcMeterDeviceModel::addMatchingMeters()
{
	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	for (int i = 0; i < allDevicesModel->count(); ++i) {
		if (Device *device = allDevicesModel->deviceAt(i)) {
			if (includeDevice(device)) {
				addMeterDevice(device);
			}
		}
	}

	updateTotals();
	updateFirstMeter();
}

bool DcMeterDeviceModel::includeDevice(Device *device)
{
	if (!device) {
		return false;
	}
	if (!m_serviceTypes.isEmpty() && !m_serviceTypes.contains(device->serviceType())) {
		return false;
	}
	if (m_meterType >= 0) {
		const int monitorMode = monitorModeForService(device->serviceItem());
		if (m_meterType != static_cast<int>(Enums::create()->dcMeter_type(device->serviceType(), monitorMode))) {
			return false;
		}
	}
	return true;
}

void DcMeterDeviceModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	const int prevCount = count();
	for (int i = first; i <= last; ++i) {
		if (Device *device = AllDevicesModel::create()->deviceAt(i)) {
			if (includeDevice(device)) {
				Q_ASSERT(indexOf(device->serviceUid()) < 0);
				beginInsertRows(QModelIndex(), m_meters.count(), m_meters.count());
				addMeterDevice(device);
				endInsertRows();
			}
		}
	}
	if (prevCount != count()) {
		updateTotals();
		updateFirstMeter();
		emit countChanged();
	}
}

void DcMeterDeviceModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	const int prevCount = count();
	for (int i = first; i <= last; ++i) {
		Device *device = AllDevicesModel::create()->deviceAt(i);
		if (!device) {
			qmlWarning(this) << "remove: cannot find device for index:" << i;
			continue;
		}
		const int deviceIndex = indexOf(device->serviceUid());
		if (deviceIndex >= 0 && deviceIndex < m_meters.count()) {
			beginRemoveRows(QModelIndex(), deviceIndex, deviceIndex);
			m_meters[deviceIndex].disconnect(this);
			m_meters.removeAt(deviceIndex);
			endRemoveRows();
		}
	}
	if (prevCount != count()) {
		updateTotals();
		updateFirstMeter();
		emit countChanged();
	}
}

void DcMeterDeviceModel::addMeterDevice(Device *device)
{
	Q_ASSERT(device);

	if (VeQItem *serviceItem = device->serviceItem()) {
		DcMeter info;
		info.device = device;

		// Use itemGetOrCreate() instead of itemGet(), as we assume these child paths are always
		// available or will become available.
		info.powerItem = serviceItem->itemGetOrCreate(QStringLiteral("Dc/0/Power"));
		if (info.powerItem) {
			connect(info.powerItem, &VeQItem::valueChanged,
					this, &DcMeterDeviceModel::scheduleUpdateTotals);
		}
		info.currentItem = serviceItem->itemGetOrCreate(QStringLiteral("Dc/0/Current"));
		if (info.currentItem) {
			connect(info.currentItem, &VeQItem::valueChanged,
					this, &DcMeterDeviceModel::scheduleUpdateTotals);
		}

		// Use itemGet() for /MonitorMode as it may not be present.
		info.monitorModeItem = serviceItem->itemGet(QStringLiteral("Settings/MonitorMode"));
		if (info.monitorModeItem) {
			connect(info.monitorModeItem, &VeQItem::valueChanged,
					this, &DcMeterDeviceModel::monitorModeChanged);
		}
		const QVariant monitorMode = info.monitorModeItem ? info.monitorModeItem->getValue() : QVariant();
		info.type = static_cast<int>(Enums::create()->dcMeter_type(device->serviceType(), monitorMode.toInt()));

		m_meters.append(info);
	}
}

void DcMeterDeviceModel::monitorModeChanged()
{
	if (VeQItem *monitorModeItem = qobject_cast<VeQItem*>(sender())) {
		for (int i = 0; i < m_meters.count(); ++i) {
			if (m_meters.at(i).monitorModeItem == monitorModeItem) {
				const QVariant monitorMode = monitorModeItem->getValue();
				const int prevMeterType = m_meters.at(i).type;
				if (m_meters.at(i).device) {
					m_meters[i].type = static_cast<int>(Enums::create()->dcMeter_type(
							m_meters.at(i).device->serviceType(), monitorMode.toInt()));
				} else {
					m_meters[i].type = -1;
				}
				if (m_meters.at(i).type != prevMeterType) {
					emit dataChanged(createIndex(i, 0), createIndex(i, 0), { MeterTypeRole });
				}
				break;
			}
		}
	}
}

void DcMeterDeviceModel::scheduleUpdateTotals()
{
	if (m_timerId == 0) {
		m_timerId = startTimer(1000);
	}
}

void DcMeterDeviceModel::timerEvent(QTimerEvent *event)
{
	Q_UNUSED(event)

	if (m_timerId > 0) {
		killTimer(m_timerId);
		m_timerId = 0;
	}
	updateTotals();
}

void DcMeterDeviceModel::updateTotals()
{
	qreal totalPower = 0;
	qreal totalCurrent = 0;

	for (int i = 0; i < m_meters.count(); ++i) {
		const DcMeter &info = m_meters.at(i);
		if (info.powerItem) {
			const QVariant value = info.powerItem->getValue();
			if (value.isValid()) {
				totalPower += value.value<qreal>();
			}
		}
		if (info.currentItem) {
			const QVariant value = info.currentItem->getValue();
			if (value.isValid()) {
				totalCurrent += value.value<qreal>();
			}
		}
	}

	if (m_totalPower != totalPower) {
		m_totalPower = totalPower;
		emit totalPowerChanged();
	}
	if (m_totalCurrent != totalCurrent) {
		m_totalCurrent = totalCurrent;
		emit totalCurrentChanged();
	}
}

void DcMeterDeviceModel::updateFirstMeter()
{
	const int prevFirstType = m_firstMeterType;
	const QString prevFirstUid = m_firstUid;

	m_firstMeterType = meterTypeAt(0);
	m_firstUid = deviceAt(0) ? deviceAt(0)->serviceUid() : QString();

	if (prevFirstUid != m_firstUid) {
		emit firstObjectChanged();
	}
	if (prevFirstType != m_firstMeterType) {
		emit firstMeterTypeChanged();
	}
}
