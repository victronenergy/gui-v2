/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "basedevice.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;


BaseDevice::BaseDevice(QObject *parent)
	: QObject(parent)
{
}

bool BaseDevice::isValid() const
{
	return !m_serviceUid.isEmpty() && (!m_productName.isEmpty() || !m_customName.isEmpty()) && m_deviceInstance >= 0;
}

QString BaseDevice::serviceUid() const
{
	return m_serviceUid;
}

void BaseDevice::setServiceUid(const QString &serviceUid)
{    
	// Service uids should not change during the lifetime of an object, as this affects the ability
	// of device models to consistently identify devices by serviceUid. Allow this behavior but
	// show a warning.
	if (!m_serviceUid.isEmpty() && m_serviceUid != serviceUid) {
		qmlInfo(this) << "Deprecated behavior! Device serviceUid already set to " << m_serviceUid << ", should not be changed again to " << serviceUid;
	}

	if (m_serviceUid != serviceUid) {
		maybeEmitValidChanged([serviceUid, this]() {
			m_serviceUid = serviceUid;
			emit serviceUidChanged();
		});
	}
}

int BaseDevice::deviceInstance() const
{
	return m_deviceInstance;
}

void BaseDevice::setDeviceInstance(int deviceInstance)
{
	if (m_deviceInstance != deviceInstance) {
		maybeEmitValidChanged([deviceInstance, this]() {
			m_deviceInstance = deviceInstance;
			emit deviceInstanceChanged();
		});
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
		maybeEmitValidChanged([productName, this]() {
			m_productName = productName;
			emit productNameChanged();
		});
	}
}

QString BaseDevice::customName() const
{
	return m_customName;
}

void BaseDevice::setCustomName(const QString &customName)
{
	if (m_customName != customName) {
		maybeEmitValidChanged([customName, this]() {
			m_customName = customName;
			emit customNameChanged();
		});
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

void BaseDevice::maybeEmitValidChanged(const std::function<void ()> &propertyChangeFunc)
{
	const bool prevValid = isValid();
	propertyChangeFunc();
	if (prevValid != isValid()) {
		emit validChanged();
	}
}

