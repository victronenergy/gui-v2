/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basedevicemodel.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;


BaseDevice::BaseDevice(QObject *parent)
	: QObject(parent)
{
}

bool BaseDevice::isValid() const
{
	return !m_serviceUid.isEmpty() && !m_productName.isEmpty() && m_deviceInstance >= 0;
}

QString BaseDevice::serviceUid() const
{
	return m_serviceUid;
}

void BaseDevice::setServiceUid(const QString &serviceUid)
{
	if (m_serviceUid != serviceUid) {
		const bool prevValid = isValid();
		m_serviceUid = serviceUid;
		emit serviceUidChanged();
		if (prevValid != isValid()) {
			emit validChanged();
		}
	}
}

int BaseDevice::deviceInstance() const
{
	return m_deviceInstance;
}

void BaseDevice::setDeviceInstance(int deviceInstance)
{
	if (m_deviceInstance != deviceInstance) {
		const bool prevValid = isValid();
		m_deviceInstance = deviceInstance;
		emit deviceInstanceChanged();
		if (prevValid != isValid()) {
			emit validChanged();
		}
	}
}

int BaseDevice::productId() const
{
	return m_productId;
}

void BaseDevice::setProductId(int productId)
{
	if (m_productId != productId) {
		m_productId = productId;
		emit productIdChanged();
	}
}

QString BaseDevice::productName() const
{
	return m_productName;
}

void BaseDevice::setProductName(const QString &productName)
{
	if (m_productName != productName) {
		const bool prevValid = isValid();
		m_productName = productName;
		emit productNameChanged();
		if (prevValid != isValid()) {
			emit validChanged();
		}
	}
}

QString BaseDevice::name() const
{
	return m_name;
}

void BaseDevice::setName(const QString &name)
{
	if (m_name != name) {
		m_name = name;
		emit nameChanged();
	}
}

QString BaseDevice::description() const
{
	return m_description;
}

void BaseDevice::setDescription(const QString &description)
{
	if (m_description != description) {
		m_description = description;
		emit descriptionChanged();
	}
}


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
	refreshFirstObject();

	return true;
}

bool BaseDeviceModel::removeDevice(const QString &serviceUid)
{
	const int index = indexOf(serviceUid);
	if (index >= 0) {
		emit beginRemoveRows(QModelIndex(), index, index);
		m_devices.removeAt(index);
		emit endRemoveRows();
		emit countChanged();
		refreshFirstObject();
		return true;
	}

	return false;
}

void BaseDeviceModel::clear()
{
	if (count() == 0) {
		return;
	}
	emit beginResetModel();
	m_devices.clear();
	emit endResetModel();
	emit countChanged();
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

int BaseDeviceModel::insertionIndex(const BaseDevice *newDevice) const
{
	if (newDevice->deviceInstance() < 0) {
		qmlInfo(this) << "warning: device " << newDevice->serviceUid() << " has invalid device instance!";
		return static_cast<int>(m_devices.count());
	}

	// Sort device list from lowest to highest deviceInstance.
	for (int i = 0; i < m_devices.count(); ++i) {
		BaseDevice *device = m_devices[i];
		if (device && device->deviceInstance() >= 0 && newDevice->deviceInstance() < device->deviceInstance()) {
			return i;
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
