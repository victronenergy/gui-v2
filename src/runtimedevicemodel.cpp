/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "runtimedevicemodel.h"
#include "alldevicesmodel.h"

#include <QQmlInfo>
#include <QQmlEngine>

using namespace Victron::VenusOS;

namespace {
bool includeServiceType(const QString &serviceType)
{
	// These device types are not shown in the Device List:
	return serviceType != QStringLiteral("generator") // found under separate 'Genset' menu
			&& serviceType != QStringLiteral("multi"); // included as part of acsystem services
}
}

RuntimeDeviceModel::RuntimeDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	AllDevicesModel *allDevicesModel = AllDevicesModel::create();
	for (int i = 0; i < allDevicesModel->count(); ++i) {
		if (BaseDevice *device = allDevicesModel->deviceAt(i)) {
			if (includeServiceType(device->serviceType())) {
				DeviceInfo info = { device, qMakePair(device->serviceType(), device->deviceInstance()), device->name() };
				m_devices.append(info);
				connect(device, &BaseDevice::nameChanged, this, &RuntimeDeviceModel::deviceNameChanged);
			}
		}
	}

	connect(allDevicesModel, &AllDevicesModel::rowsInserted,
			this, &RuntimeDeviceModel::sourceDeviceAdded);
	connect(allDevicesModel, &AllDevicesModel::rowsAboutToBeRemoved,
			this, &RuntimeDeviceModel::sourceDeviceAboutToBeRemoved);
	connect(allDevicesModel, &AllDevicesModel::modelAboutToBeReset,
			this, &RuntimeDeviceModel::sourceDevicesAboutToBeReset);
}

int RuntimeDeviceModel::count() const
{
	return m_devices.count();
}

int RuntimeDeviceModel::disconnectedDeviceCount() const
{
	return m_disconnectedDevices.count();
}

QVariant RuntimeDeviceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();
	if (row < 0 || row >= m_devices.count()) {
		return QVariant();
	}

	switch (role)
	{
	case DeviceRole:
		return m_devices.at(row).device ? QVariant::fromValue<BaseDevice *>(m_devices.at(row).device) : QVariant();
	case CachedDeviceNameRole:
		return m_devices.at(row).cachedName;
	case ConnectedRole:
		return m_devices.at(row).device != nullptr;
	default:
		return QVariant();
	}
}
int RuntimeDeviceModel::rowCount(const QModelIndex &) const
{
	return count();
}

QHash<int, QByteArray> RuntimeDeviceModel::roleNames() const
{
	static const QHash<int, QByteArray> roles {
		{ DeviceRole, "device" },
		{ CachedDeviceNameRole, "cachedDeviceName" },
		{ ConnectedRole, "connected" },
	};
	return roles;
}

BaseDevice *RuntimeDeviceModel::deviceAt(int index) const
{
	if (index >= 0 && index < m_devices.count()) {
		return m_devices.at(index).device;
	}
	return nullptr;
}

void RuntimeDeviceModel::removeDisconnectedDevices()
{
	if (m_disconnectedDevices.isEmpty()) {
		return;
	}

	for (auto it = m_disconnectedDevices.begin(); it != m_disconnectedDevices.end();) {
		const int index = indexOf(it->first, it->second);
		if (index >= 0) {
			beginRemoveRows(QModelIndex(), index, index);
			m_devices.removeAt(index);
			endRemoveRows();
		} else {
			qmlWarning(this) << "Cannot find disconnected device: " << it->first << ", " << it->second;
		}
		it = m_disconnectedDevices.erase(it);
	}

	emit countChanged();
	emit disconnectedDeviceCountChanged();
}

int RuntimeDeviceModel::indexOf(const QString &serviceType, int deviceInstance) const
{
	if (serviceType.isEmpty()) {
		qmlWarning(this) << "Cannot find invalid serviceType!";
		return -1;
	}
	if (deviceInstance < 0) {
		qmlWarning(this) << "Cannot find invalid deviceInstance! Service type is: " << serviceType;
		return -1;
	}

	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices.at(i).id.first == serviceType && m_devices.at(i).id.second == deviceInstance) {
			return i;
		}
	}
	return -1;
}

int RuntimeDeviceModel::indexOfKnownDevice(BaseDevice *device) const
{
	if (!device) {
		qmlWarning(this) << "Cannot find invalid device!";
		return -1;
	}

	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices.at(i).device == device) {
			return i;
		}
	}
	return -1;
}

void RuntimeDeviceModel::deviceNameChanged()
{
	if (BaseDevice *device = qobject_cast<BaseDevice *>(sender())) {
		if (const int deviceIndex = indexOfKnownDevice(device); deviceIndex >= 0) {
			m_devices[deviceIndex].cachedName = device->name();
			emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), { CachedDeviceNameRole });
		}
	}
}

void RuntimeDeviceModel::sourceDeviceAdded(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	const int prevDisconnectedCount = disconnectedDeviceCount();

	for (int i = first; i <= last; ++i) {
		if (BaseDevice *device = AllDevicesModel::create()->deviceAt(i)) {
			if (!includeServiceType(device->serviceType())) {
				continue;
			}

			const int deviceIndex = indexOf(device->serviceType(), device->deviceInstance());
			if (deviceIndex < 0) {
				// This is a new device, so add it to the model.
				DeviceInfo info = { device, qMakePair(device->serviceType(), device->deviceInstance()), device->name() };
				beginInsertRows(QModelIndex(), m_devices.count(), m_devices.count());
				m_devices.append(info);
				endInsertRows();
				emit countChanged();

				// Be notified when the device name changes.
				connect(device, &BaseDevice::nameChanged, this, &RuntimeDeviceModel::deviceNameChanged);
			} else {
				// The device id is already in the model; this means it was disconnected, and has now been reconnected.
				if (m_devices.at(deviceIndex).device) {
					qmlWarning(this) << "Updating device, expected null device but pointer is still valid: "
							<< m_devices.at(deviceIndex).device->serviceUid();
					emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), { ConnectedRole });
				} else {
					QList<int> changedRoles = { ConnectedRole, DeviceRole };
					m_devices[deviceIndex].device = device;
					if (m_devices[deviceIndex].cachedName != device->name()) {
						m_devices[deviceIndex].cachedName = device->name();
						changedRoles.append(CachedDeviceNameRole);
					}
					emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), changedRoles);
					connect(device, &BaseDevice::nameChanged, this, &RuntimeDeviceModel::deviceNameChanged);
				}
				m_disconnectedDevices.remove(m_devices.at(deviceIndex).id);
			}
		}
	}

	if (disconnectedDeviceCount() != prevDisconnectedCount) {
		emit disconnectedDeviceCountChanged();
	}
}

void RuntimeDeviceModel::sourceDeviceAboutToBeRemoved(const QModelIndex &parent, int first, int last)
{
	Q_UNUSED(parent)

	const int prevDisconnectedCount = disconnectedDeviceCount();

	for (int i = first; i <= last; ++i) {
		if (BaseDevice *device = AllDevicesModel::create()->deviceAt(i)) {
			const int deviceIndex = indexOfKnownDevice(device);
			if (deviceIndex < 0) {
				qmlWarning(this) << "Cannot find device that was removed from source: " << device->serviceUid();
				continue;
			}
			// Mark the device as disconnected.
			m_disconnectedDevices.insert(m_devices[deviceIndex].id);

			// Clear the device pointer for the list entry.
			if (m_devices[deviceIndex].device) {
				m_devices[deviceIndex].device->disconnect(this);
				m_devices[deviceIndex].device = nullptr;
			}
			emit dataChanged(createIndex(deviceIndex, 0), createIndex(deviceIndex, 0), { ConnectedRole, DeviceRole });
		}
	}

	if (disconnectedDeviceCount() != prevDisconnectedCount) {
		emit disconnectedDeviceCountChanged();
	}
}

void RuntimeDeviceModel::sourceDevicesAboutToBeReset()
{
	if (m_devices.isEmpty()) {
		return;
	}

	const int prevDisconnectedCount = disconnectedDeviceCount();

	beginResetModel();
	for (const DeviceInfo &info : m_devices) {
		if (info.device) {
			info.device->disconnect(this);
		}
	}
	m_devices.clear();
	m_disconnectedDevices.clear();
	endResetModel();
	emit countChanged();

	if (disconnectedDeviceCount() != prevDisconnectedCount) {
		emit disconnectedDeviceCountChanged();
	}
}

RuntimeDeviceModel* RuntimeDeviceModel::create(QQmlEngine *engine, QJSEngine *)
{
	static RuntimeDeviceModel* instance = new RuntimeDeviceModel(engine);
	return instance;
}


SortedRuntimeDeviceModel::SortedRuntimeDeviceModel(QObject *parent)
	: QSortFilterProxyModel(parent)
{
	setSortLocaleAware(true);
	setSortRole(RuntimeDeviceModel::CachedDeviceNameRole);
	sort(0, Qt::AscendingOrder);
}
