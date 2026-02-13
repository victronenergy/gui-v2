/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "iochannel.h"
#include "backendconnection.h"
#include "alldevicesmodel.h"
#include "enums.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

IOChannel::IOChannel(Direction direction, QObject *parent)
	: QObject(parent)
	, m_direction(direction)
{
}

void IOChannel::initialize(VeQItem *item)
{
	if (m_item) {
		m_item->disconnect(this);
	}
	m_item = item;

	if (m_item) {
		m_serviceUid = m_item->itemParent() // the /GenericInput or /SwitchableOutput parent
				&& m_item->itemParent()->itemParent() // the root service item
				? m_item->itemParent()->itemParent()->uniqueId()
				: QString();

		// Set up BaseDevice member pointer, in order to update the formatted name when the device's
		// product/custom name or device instance changes.
		if (BaseDevice::serviceTypeFromUid(m_serviceUid) != QStringLiteral("system")) {
			m_device = AllDevicesModel::create()->findDevice(m_serviceUid);
			if (m_device) {
				connect(m_device, &BaseDevice::productNameChanged, this, &IOChannel::updateFormattedName);
				connect(m_device, &BaseDevice::customNameChanged, this, &IOChannel::updateFormattedName);
				connect(m_device, &BaseDevice::deviceInstanceChanged, this, &IOChannel::updateFormattedName);
			}
		}

		// Set up configuration for the formattedName.
		if (VeQItem *nameItem = m_item->itemGetOrCreate(QStringLiteral("Name"))) {
			connect(nameItem, &VeQItem::valueChanged, this, [this](QVariant variant) {
				m_name = variant.toString();
				updateFormattedName();
			});
			m_name = nameItem->getValue().toString();
			updateFormattedName();
		}
		if (VeQItem *customNameItem = m_item->itemGetOrCreate(QStringLiteral("Settings/CustomName"))) {
			connect(customNameItem, &VeQItem::valueChanged, this, [this](QVariant variant) {
				m_customName = variant.toString();
				updateFormattedName();
			});
			m_customName = customNameItem->getValue().toString();
			updateFormattedName();
		}

		// Set up other property values.
		if (VeQItem *statusItem = m_item->itemGetOrCreate(QStringLiteral("Status"))) {
			connect(statusItem, &VeQItem::valueChanged, this, &IOChannel::setStatus);
			setStatus(statusItem->getValue());
		}
		if (VeQItem *typeItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Type"))) {
			connect(typeItem, &VeQItem::valueChanged, this, &IOChannel::setType);
			setType(typeItem->getValue().isValid() ? typeItem->getValue() : -1);
		}
		if (VeQItem *validTypesItem = m_item->itemGetOrCreate(QStringLiteral("Settings/ValidTypes"))) {
			connect(validTypesItem, &VeQItem::valueChanged, this, &IOChannel::setValidTypes);
			setValidTypes(validTypesItem->getValue());
		}
		if (VeQItem *groupItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Group"))) {
			connect(groupItem, &VeQItem::valueChanged, this, &IOChannel::setGroup);
			setGroup(groupItem->getValue());
		}
		if (VeQItem *unitItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Unit"))) {
			connect(unitItem, &VeQItem::valueChanged, this, &IOChannel::setUnit);
			setUnit(unitItem->getValue());
		}
		if (VeQItem *decimalsItem = m_item->itemGetOrCreate(QStringLiteral("Settings/Decimals"))) {
			connect(decimalsItem, &VeQItem::valueChanged, this, &IOChannel::setDecimals);
			setDecimals(decimalsItem->getValue());
		}
	} else {
		m_serviceUid.clear();

		// Clear member pointers.
		if (m_device) {
			m_device->disconnect();
			m_device.clear();
		}

		// Clear formatted name.
		m_name.clear();
		m_customName.clear();
		updateFormattedName();

		// Clear other member variables.
		setStatus(QVariant());
		setType(QVariant(-1));
		setValidTypes(QVariant());
		setGroup(QVariant());
		setUnit(QVariant());
		setDecimals(QVariant());
	}

	emit channelIdChanged();
	emit serviceUidChanged();
	emit uidChanged();
}

QString IOChannel::uid() const
{
	return m_item ? m_item->uniqueId() : QString();
}

void IOChannel::setUid(const QString &uid)
{
	if ((uid.isEmpty() && !m_item)
		|| (m_item && uid == m_item->uniqueId())) {
		return;
	}

	initialize(uid.isEmpty() ? nullptr : VeQItems::getRoot()->itemGet(uid));
}

QString IOChannel::serviceUid() const
{
	return m_serviceUid;
}

QString IOChannel::channelId() const
{
	return m_item ? m_item->id() : QString();
}

IOChannel::Direction IOChannel::direction() const
{
	return m_direction;
}

QString IOChannel::formattedName() const
{
	return m_formattedName;
}

int IOChannel::status() const
{
	return m_status;
}

void IOChannel::setStatus(const QVariant &variant)
{
	m_status = variant.toInt();
	emit statusChanged();
}

int IOChannel::type() const
{
	return m_type;
}

void IOChannel::setType(const QVariant &variant)
{
	m_type = variant.toInt();
	updateHasValidType();
	emit typeChanged();
}

int IOChannel::validTypes() const
{
	return m_validTypes;
}

void IOChannel::setValidTypes(const QVariant &variant)
{
	m_validTypes = variant.toInt();
	updateHasValidType();
	emit validTypesChanged();
}

bool IOChannel::hasValidType() const
{
	return m_hasValidType;
}

void IOChannel::updateHasValidType()
{
	const int typeInt = type();
	const bool hasValidType = typeInt >= minimumType() && typeInt <= maximumType()
			&& (validTypes() & (1 << typeInt));
	if (hasValidType != m_hasValidType) {
		m_hasValidType = hasValidType;
		updateAllowedInGroupModel();
		emit hasValidTypeChanged();
	}
}

QString IOChannel::group() const
{
	return m_group;
}

void IOChannel::setGroup(const QVariant &variant)
{
	m_group = variant.toString();
	updateFormattedName();
	emit groupChanged();
}

bool IOChannel::allowedInGroupModel() const
{
	return m_allowedInGroupModel;
}

int IOChannel::unitType() const
{
	return m_unitType;
}

QString IOChannel::unitText() const
{
	return m_unitText;
}

void IOChannel::setUnit(const QVariant &variant)
{
	const QString unitText = variant.toString();
	int unitType = Enums::Units_None;

	// get the base unit
	if (unitText == QStringLiteral("/Speed")) {
		unitType = Enums::Units_Speed_MetresPerSecond;
	} else if (unitText == QStringLiteral("/Temperature")) {
		unitType = Enums::Units_Temperature_Celsius;
	} else if (unitText == QStringLiteral("/Volume")) {
		unitType = Enums::Units_Volume_CubicMetre;
	}

	if (unitType != m_unitType) {
		m_unitType = unitType;
		emit unitTypeChanged();
	}
	if (unitText != m_unitText) {
		m_unitText = unitText;
		emit unitTextChanged();
	}
}

int IOChannel::decimals() const
{
	return m_decimals;
}

void IOChannel::setDecimals(const QVariant &variant)
{
	m_decimalsVariant = variant.toInt();
	updateDecimals();
}

int IOChannel::getDecimals() const
{
	return m_decimalsVariant.toInt();
}

void IOChannel::updateDecimals()
{
	const int d = getDecimals();
	if (d != m_decimals) {
		m_decimals = d;
		emit decimalsChanged();
	}
}

bool IOChannel::getAllowedInGroupModel() const
{
	return hasValidType();
}

void IOChannel::updateAllowedInGroupModel()
{
	const bool allowed = getAllowedInGroupModel();
	if (allowed != m_allowedInGroupModel) {
		m_allowedInGroupModel = allowed;
		emit allowedInGroupModelChanged();
	}
}

bool IOChannel::canShowUI(const QVariant &showUIValue) const
{
	if (!showUIValue.isValid()) {
		// If /ShowUIInput or /ShowUIControl is not present, then allow the control to be shown.
		return true;
	}

	// Check the /ShowUIControl value:
	// - Off = do not show
	// - Local = show for local viewing only (i.e. on GX or Wasm local)
	// - Remote = show for remote viewing only (i.e. on Wasm VRM)
	const int intValue = showUIValue.toInt();
	if (intValue == Enums::IOChannel_ShowUI_Off) {
		return false;
	}

	const bool local = intValue & Enums::IOChannel_ShowUI_Local;
	const bool remote = intValue & Enums::IOChannel_ShowUI_Remote;
	if ((intValue & Enums::IOChannel_ShowUI_Always)
			// Setting both local+remote flags is the same as setting the "always" flag, regardless
			// of the VRM connection status. It's not possible to set both flags via the UI, but
			// this might be set by a backend configuration.
			|| (local && remote)) {
		return true;
	}

	if ((local && !BackendConnection::create()->isVrm())
			|| (remote && BackendConnection::create()->isVrm())) {
		return true;
	}

	// The VRM connection status doesn't match the local/remote visibility preference.
	return false;
}
void IOChannel::updateFormattedName()
{
	QString newFormattedName;

	if (m_customName.length() > 0) {
		newFormattedName = m_customName;
	} else if (m_group.length() > 0) {
		// When the channel is in a named group (where it might be in the same group as channels
		// from other devices) then use a name that identifies the source device/service.
		QString prefix;
		if (!m_serviceUid.isEmpty()
				&& BaseDevice::serviceTypeFromUid(m_serviceUid) == QStringLiteral("system")) {
			//% "GX device relays"
			prefix = qtTrId("switchableoutput_gx_device_relays");
		} else if (m_device) {
			prefix = m_device->customName().length() > 0
					? m_device->customName()
					: QStringLiteral("%1 (%2)").arg(m_device->productName()).arg(m_device->deviceInstance());
		}
		newFormattedName = QStringLiteral("%1 | %2").arg(prefix).arg(m_name);
	} else {
		// When the channel is in the default group for the device, instead of in a named group,
		// then the /Name can be used directly.
		newFormattedName = m_name;
	}

	if (m_formattedName != newFormattedName) {
		m_formattedName = newFormattedName;
		emit formattedNameChanged();
	}
}
