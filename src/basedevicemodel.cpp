/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basedevicemodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;


BaseDeviceModel::BaseDeviceModel(QObject *parent)
	: QAbstractListModel(parent)
{
	m_roleNames[DeviceRole] = "device";
}

BaseDevice *BaseDeviceModel::firstObject() const
{
	return m_firstObject.data();
}

int BaseDeviceModel::count() const
{
	return static_cast<int>(m_devices.count());
}

QString BaseDeviceModel::modelId() const
{
	return m_modelId;
}

void BaseDeviceModel::setModelId(const QString &modelId)
{
	if (m_modelId != modelId) {
		m_modelId = modelId;
		emit modelIdChanged();
	}
}

void BaseDeviceModel::setSortBy(int sortBy)
{
	if (count() > 0) {
		qmlInfo(this) << "Changing sort order after initialization is not supported";
		return;
	}

	if (m_sortBy != sortBy) {
		m_sortBy = sortBy;
		emit sortByChanged();
	}
}

int BaseDeviceModel::sortBy() const
{
	return m_sortBy;
}

QVariant BaseDeviceModel::data(const QModelIndex &index, int role) const
{
	const int row = index.row();

	if(row < 0 || row >= m_devices.count()) {
		return QVariant();
	}
	switch (role)
	{
	case DeviceRole:
		return QVariant::fromValue<BaseDevice*>(m_devices.at(row).data());
	default:
		return QVariant();
	}
}

int BaseDeviceModel::rowCount(const QModelIndex &) const
{
	return static_cast<int>(m_devices.count());
}

QHash<int, QByteArray> BaseDeviceModel::roleNames() const
{
	return m_roleNames;
}

bool BaseDeviceModel::addDevice(BaseDevice *device)
{
	if (!device) {
		qmlInfo(this) << "cannot add device, invalid device!";
		return false;
	}
	if (device->serviceUid().length() == 0) {
		qmlInfo(this) << "cannot add device, no serviceUid!";
		return false;
	}
	if (device->deviceInstance() < 0) {
		qmlInfo(this) << "model not adding device, invalid device instance for: " << device->serviceUid();
		return false;
	}
	if (indexOf(device->serviceUid()) >= 0) {
		qmlInfo(this) << "model not adding device, already contains: " << device->serviceUid();
		return false;
	}

	const int index = insertionIndex(device);
	emit beginInsertRows(QModelIndex(), index, index);
	m_devices.insert(index, device);
	emit endInsertRows();
	emit countChanged();

	connect(device, &BaseDevice::nameChanged, this, &BaseDeviceModel::deviceNameChanged);
	refreshFirstObject();

	return true;
}

bool BaseDeviceModel::removeDevice(const QString &serviceUid)
{
	return removeAt(indexOf(serviceUid));
}

bool BaseDeviceModel::removeAt(int index)
{
	if (index >= 0 && index < count()) {
		emit beginRemoveRows(QModelIndex(), index, index);
		BaseDevice *device = m_devices.takeAt(index);
		if (device) {
			device->disconnect(this);
		}
		emit endRemoveRows();
		emit countChanged();
		refreshFirstObject();
		return true;
	}
	return false;
}

void BaseDeviceModel::intersect(const QStringList &serviceUids)
{
	for (int i = m_devices.count() - 1; i >= 0; --i) {
		const QString serviceUid = m_devices[i] ? m_devices[i]->serviceUid() : QString();
		if (serviceUid.length() && serviceUids.indexOf(serviceUid) < 0) {
			removeDevice(serviceUid);
		}
	}
}

void BaseDeviceModel::clear()
{
	if (count() == 0) {
		return;
	}
	emit beginResetModel();
	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices[i]) {
			m_devices[i]->disconnect(this);
		}
	}
	m_devices.clear();
	emit endResetModel();
	emit countChanged();
}

void BaseDeviceModel::deleteAllAndClear()
{
	qDeleteAll(m_devices);
	m_devices.clear();
}

int BaseDeviceModel::indexOf(const QString &serviceUid) const
{
	for (int i = 0; i < m_devices.count(); ++i) {
		if (m_devices[i] && m_devices[i]->serviceUid() == serviceUid) {
			return i;
		}
	}
	return -1;
}

BaseDevice *BaseDeviceModel::deviceForDeviceInstance(int deviceInstance) const
{
	for (BaseDevice *device : m_devices) {
		if (device && device->deviceInstance() == deviceInstance) {
			return device;
		}
	}
	return nullptr;
}

BaseDevice *BaseDeviceModel::deviceAt(int index) const
{
	if (index < 0 || index >= m_devices.count()) {
		return nullptr;
	}
	return m_devices.at(index);
}

void BaseDeviceModel::deviceNameChanged()
{
	BaseDevice *changedDevice = qobject_cast<BaseDevice *>(sender());
	if (!changedDevice) {
		qmlInfo(this) << "nameChanged() signal was not from a BaseDevice!";
		return;
	}

	const int fromIndex = indexOf(changedDevice->serviceUid());
	if (fromIndex < 0 || m_devices.count() == 0) {
		return;
	}

	// Update the list order if needed
	int toIndex = count() - 1;
	for (int i = 0; i < m_devices.count(); ++i) {
		if (lessThan(changedDevice, m_devices[i])) {
			if (i > 0 && m_devices[i - 1] == changedDevice) {
				// The device at the previous index is this changed device, so it is already at
				// the correct index.
				return;
			}
			// Move the entry to be immediately before this item.
			toIndex = i > fromIndex ? i - 1 : i;
			break;
		}
	}

	if (fromIndex != toIndex) {
		const int destIndex = toIndex > fromIndex ? toIndex + 1 : toIndex;
		beginMoveRows(QModelIndex(), fromIndex, fromIndex, QModelIndex(), destIndex);
		m_devices.move(fromIndex, toIndex);
		endMoveRows();

		if (fromIndex == 0 || toIndex == 0) {
			refreshFirstObject();
		}
	}
}

bool BaseDeviceModel::lessThan(const BaseDevice *deviceA, const BaseDevice *deviceB) const
{
	if (!deviceA || !deviceB || deviceA == deviceB) {
		return false;
	}

	if (m_sortBy == SortByDeviceName) {
		if (deviceA->name().localeAwareCompare(deviceB->name()) < 0) {
			return true;
		}
	} else if (m_sortBy == SortByDeviceInstance) {
		if (deviceA->deviceInstance() < deviceB->deviceInstance()) {
			return true;
		}
	}
	return false;
}

int BaseDeviceModel::insertionIndex(const BaseDevice *newDevice) const
{
	if (newDevice->deviceInstance() < 0) {
		qmlInfo(this) << "warning: device " << newDevice->serviceUid() << " has invalid device instance!";
		return static_cast<int>(m_devices.count());
	}

	if (m_sortBy != 0) {
		for (int i = 0; i < m_devices.count(); ++i) {
			if (lessThan(newDevice, m_devices[i])) {
				return i;
			}
		}
	}
	return static_cast<int>(m_devices.count());
}

void BaseDeviceModel::refreshFirstObject()
{
	if (m_devices.count() == 0) {
		if (!m_firstObject.isNull()) {
			m_firstObject.clear();
			emit firstObjectChanged();
		}
	} else if (m_firstObject != m_devices.at(0)) {
		m_firstObject = m_devices.at(0);
		emit firstObjectChanged();
	}
}
