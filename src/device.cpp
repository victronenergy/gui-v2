/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "device.h"
#include "allservicesmodel.h"
#include "enums.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

Device::Device(QObject *parent)
	: BaseDevice(parent)
{
	connect(this, &Device::serviceUidChanged, this, &Device::initializeFromServiceUid);
}

Device::Device(QObject *parent, VeQItem *serviceItem)
	: BaseDevice(parent)
{
	setServiceItem(serviceItem);
}

VeQItem *Device::serviceItem() const
{
	return m_serviceItem;
}

void Device::setServiceItem(VeQItem *serviceItem)
{
	if (!serviceItem) {
		qWarning() << "Setting invalid serviceItem for Device!";
		return;
	}
	if (m_serviceItem) {
		qWarning() << "Service item already set for" << serviceUid() << ", ignoring request to set it";
		return;
	}

	m_serviceItem = serviceItem;

	QStringList watchedIds = {
		QStringLiteral("DeviceInstance"),
		QStringLiteral("CustomName"),
		QStringLiteral("ProductName"),
		QStringLiteral("ProductId"),
	};
	setServiceUid(m_serviceItem->uniqueId());

	// For tanks, the fluid type may be used by refreshName(). Ideally this would be handled by a
	// TankDevice subclass, but putting it in this class allows this type to be used generically in
	// QML regardless of the service type.
	if (serviceType() == QStringLiteral("tank")) {
		watchedIds.append(QStringLiteral("FluidType"));
		connect(this, &Device::deviceInstanceChanged, this, &Device::refreshName);
	}

	for (auto it = watchedIds.begin(); it != watchedIds.end(); ++it) {
		if (VeQItem *item = m_serviceItem->itemGet(*it)) {
			serviceChildAdded(item);
		}
	}

	refreshName();
	connect(m_serviceItem, &VeQItem::childAdded, this, &Device::serviceChildAdded);
	connect(m_serviceItem, &VeQItem::childAboutToBeRemoved, this, &Device::serviceChildAboutToBeRemoved);
}

void Device::serviceChildAdded(VeQItem *child)
{
	if (child->id() == QStringLiteral("DeviceInstance")) {
		const QVariant value = child->getValue();
		if (value.isValid()) {
			setDeviceInstance(value.toInt());
		}
		connect(child, &VeQItem::valueChanged, this, [this](QVariant value) {
			setDeviceInstance(value.isValid() ? value.toInt() : -1);
		});
	} else if (child->id() == QStringLiteral("CustomName")) {
		m_customNameItem = child;
		setCustomName(child->getValue().toString());
		connect(child, &VeQItem::valueChanged, this, [this](QVariant value) {
			setCustomName(value.toString());
			refreshName();
		});
	} else if (child->id() == QStringLiteral("ProductName")) {
		m_productNameItem = child;
		setProductName(child->getValue().toString());
		connect(child, &VeQItem::valueChanged, this, [this](QVariant value) {
			setProductName(value.toString());
			refreshName();
		});
	} else if (child->id() == QStringLiteral("ProductId")) {
		setProductId(child->getValue().toInt());
		connect(child, &VeQItem::valueChanged, this, [this](QVariant value) {
			setProductId(value.toInt());
		});
	} else if (child->id() == QStringLiteral("FluidType") && serviceType() == QStringLiteral("tank")) {
		const QVariant value = child->getValue();
		if (value.isValid()) {
			m_fluidType = value.toInt();
		}
		connect(child, &VeQItem::valueChanged, this, [this](QVariant value) {
			m_fluidType = value.isValid() ? value.toInt() : -1;
			refreshName();
		});
	}
}

void Device::serviceChildAboutToBeRemoved(VeQItem *child)
{
	if (child->id() == QStringLiteral("CustomName")) {
		m_customNameItem = nullptr;
	} else if (child->id() == QStringLiteral("ProductName")) {
		m_productNameItem = nullptr;
	}
}

void Device::refreshName()
{
	// When some devices (eg. BMSes), are turned off, the custom name value changes to 'undefined'
	// before they become invalid. See https://github.com/victronenergy/gui-v2/issues/1705.
	// Check the custom name state to avoid using it when invalid.
	if (m_customNameItem
			&& m_customNameItem->getState() == VeQItem::Synchronized
			&& !customName().isEmpty()) {
		setName(customName());
	} else if (m_fluidType >= 0 && deviceInstance() >= 0) {
		//: Tank description. %1 = tank type (e.g. Fuel, Fresh water), %2 = tank device instance (a number)
		//% "%1 tank (%2)"
		setName(qtTrId("tank_description")
				.arg(Enums::create()->tank_fluidTypeToText(static_cast<Enums::Tank_Type>(m_fluidType)))
				.arg(deviceInstance()));
	} else if (m_serviceItem->getState() != VeQItem::Offline
			&& ((m_customNameItem && m_customNameItem->getState() == VeQItem::Offline) || customName().isEmpty())
			&& m_productNameItem && m_productNameItem->getState() == VeQItem::Synchronized) {
		setName(productName());
	}
}

void Device::initializeFromServiceUid()
{
	if (!serviceUid().isEmpty() && !m_serviceItem) {
		disconnect(this, &Device::serviceUidChanged, this, &Device::initializeFromServiceUid);

		AllServicesModel *allServicesModel = AllServicesModel::create();
		VeQItem *serviceItem = allServicesModel->itemAt(allServicesModel->indexOf(serviceUid()));
		if (serviceItem) {
			setServiceItem(serviceItem);
		} else {
			connect(allServicesModel, &AllServicesModel::serviceAdded, this, [this](VeQItem *item) {
				if (!m_serviceItem && item->uniqueId() == serviceUid()) {
					AllServicesModel::create()->disconnect(this);
					setServiceItem(item);
				}
			});
		}
	}
}
