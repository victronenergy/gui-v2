/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "switchableoutput.h"
#include "alldevicesmodel.h"
#include "allservicesmodel.h"
#include "enums.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

SwitchableOutput::SwitchableOutput(QObject *parent)
	: QObject(parent)
{
}

SwitchableOutput::SwitchableOutput(QObject *parent, VeQItem *outputItem)
	: QObject(parent)
{
	initialize(outputItem);
}

void SwitchableOutput::initialize(VeQItem *outputItem)
{
	// Expected outputItem uid:
	// D-Bus/Mock: <dbus|mock>/com.victronenergy.<serviceType>[.suffix]/SwitchableOutput/<outputId>
	// MQTT: mqtt/<serviceType>/<deviceInstance>/SwitchableOutput/<outputId>
	if (!outputItem
			|| !outputItem->itemParent() // the /SwitchableOutput parent
			|| !outputItem->itemParent()->itemParent()) {   // the root service item
		qWarning() << "initialize() failed: invalid SwitchableOutput VeQItem!";
		return;
	}

	m_outputItem = outputItem;

	VeQItem *serviceItem = outputItem->itemParent()->itemParent();
	m_serviceUid = serviceItem->uniqueId();

	// Initialize the main properties
	if (VeQItem *stateItem = m_outputItem->itemGetOrCreate(QStringLiteral("State"))) {
		m_stateItem = stateItem;
		connect(stateItem, &VeQItem::valueChanged, this, &SwitchableOutput::stateChanged);
	}
	if (VeQItem *statusItem = m_outputItem->itemGetOrCreate(QStringLiteral("Status"))) {
		m_statusItem = statusItem;
		connect(statusItem, &VeQItem::valueChanged, this, &SwitchableOutput::statusChanged);
	}
	if (VeQItem *nameItem = m_outputItem->itemGetOrCreate(QStringLiteral("Name"))) {
		m_nameItem = nameItem;
		connect(nameItem, &VeQItem::valueChanged, this, &SwitchableOutput::updateFormattedName);
	}
	if (VeQItem *dimmingItem = m_outputItem->itemGetOrCreate(QStringLiteral("Dimming"))) {
		m_dimmingItem = dimmingItem;
		connect(dimmingItem, &VeQItem::valueChanged, this, &SwitchableOutput::dimmingChanged);
	}

	// Initialize the settings properties
	if (VeQItem *typeItem = m_outputItem->itemGetOrCreate(QStringLiteral("Settings/Type"))) {
		m_typeItem = typeItem;
		connect(typeItem, &VeQItem::valueChanged, this, &SwitchableOutput::setTypeFromVariant);
	}
	if (VeQItem *groupItem = m_outputItem->itemGetOrCreate(QStringLiteral("Settings/Group"))) {
		m_groupItem = groupItem;
		connect(groupItem, &VeQItem::valueChanged, this, &SwitchableOutput::groupChanged);
	}
	if (VeQItem *customNameItem = m_outputItem->itemGetOrCreate(QStringLiteral("Settings/CustomName"))) {
		m_customNameItem = customNameItem;
		connect(customNameItem, &VeQItem::valueChanged, this, &SwitchableOutput::updateFormattedName);
	}
	if (VeQItem *showUIControlItem = m_outputItem->itemGetOrCreate(QStringLiteral("Settings/ShowUIControl"))) {
		m_showUIControlItem = showUIControlItem;
		connect(showUIControlItem, &VeQItem::valueChanged, this, &SwitchableOutput::updateAllowedInGroupModel);
	}

	// Optional values - call itemGet() instead of itemGetOrCreate().
	if (VeQItem *unitItem = m_outputItem->itemGet(QStringLiteral("Settings/Unit"))) {
		connect(unitItem, &VeQItem::valueChanged, this, &SwitchableOutput::setUnit);
		setUnit(unitItem->getValue());
	} else {
		setUnit(QVariant());
	}
	if (VeQItem *decimalsItem = m_outputItem->itemGet(QStringLiteral("Settings/Decimals"))) {
		connect(decimalsItem, &VeQItem::valueChanged, this, &SwitchableOutput::setDecimals);
		setDecimals(decimalsItem->getValue());
	} else {
		setDecimals(QVariant());
	}
	if (VeQItem *stepSizeItem = m_outputItem->itemGet(QStringLiteral("Settings/StepSize"))) {
		connect(stepSizeItem, &VeQItem::valueChanged, this, &SwitchableOutput::updateDecimalsFromStepSize);
		updateDecimalsFromStepSize(stepSizeItem->getValue());
	} else {
		updateDecimalsFromStepSize(QVariant());
	}

	// Update the formatted name when the device's product/custom name or device instance changes.
	if (BaseDevice::serviceTypeFromUid(m_serviceUid) != QStringLiteral("system")) {
		m_device = AllDevicesModel::create()->findDevice(m_serviceUid);
		if (m_device) {
			connect(m_device, &BaseDevice::productNameChanged, this, &SwitchableOutput::updateFormattedName);
			connect(m_device, &BaseDevice::customNameChanged, this, &SwitchableOutput::updateFormattedName);
			connect(m_device, &BaseDevice::deviceInstanceChanged, this, &SwitchableOutput::updateFormattedName);
		}
	}

	// Fetch Settings/Function for system relays.
	if (BaseDevice::serviceTypeFromUid(m_serviceUid) == QStringLiteral("system")) {
		if (VeQItem *relayFunctionItem = m_outputItem->itemGetOrCreate(QStringLiteral("Settings/Function"))) {
			m_relayFunctionItem = relayFunctionItem;
			connect(relayFunctionItem, &VeQItem::valueChanged, this, &SwitchableOutput::updateAllowedInGroupModel);
		}
	}

	updateFormattedName();
	updateAllowedInGroupModel();
}

void SwitchableOutput::reset()
{
	// Clear properties provided by VeQItem members.
	const QList<QPointer<VeQItem> *> items = {
		&m_outputItem,
		&m_stateItem, &m_statusItem, &m_nameItem, &m_dimmingItem,
		&m_typeItem,  &m_groupItem, &m_customNameItem, &m_showUIControlItem,
		&m_relayFunctionItem
	};
	for (QPointer<VeQItem> *item : items) {
		if (item->data()) {
			item->data()->disconnect(this);
			item->clear();
		}
	}

	// Clear properties for which there are no VeQItem members.
	setUnit(QVariant());
	setDecimals(QVariant());
	updateDecimalsFromStepSize(QVariant());

	if (m_device) {
		m_device->disconnect(this);
		m_device.clear();
	}

	m_serviceUid.clear();
	updateFormattedName();
	updateAllowedInGroupModel();
}

QString SwitchableOutput::uid() const
{
	return m_outputItem ? m_outputItem->uniqueId() : QString();
}

void SwitchableOutput::setUid(const QString &uid)
{
	if ((uid.isEmpty() && !m_outputItem)
		|| (m_outputItem && uid == m_outputItem->uniqueId())) {
		return;
	}

	const QString prevFormattedName = formattedName();
	const int prevState = state();
	const int prevStatus = status();
	const qreal prevDimming = dimming();
	const int prevType = type();
	const QString prevGroup = group();
	const bool prevAllowedInGroupModel = allowedInGroupModel();

	reset();

	if (!uid.isEmpty()) {
		if (VeQItem *outputItem = VeQItems::getRoot()->itemGet(uid)) {
			initialize(outputItem);
			if (prevFormattedName != formattedName()) {
				emit formattedNameChanged();
			}
			if (prevState != state()) {
				emit stateChanged();
			}
			if (prevStatus != status()) {
				emit statusChanged();
			}
			if (prevDimming != dimming()) {
				emit dimmingChanged();
			}
			if (prevType != type()) {
				emit typeChanged();
			}
			if (prevGroup != group()) {
				emit groupChanged();
			}
			if (prevAllowedInGroupModel != allowedInGroupModel()) {
				emit allowedInGroupModelChanged();
			}
		} else {
			qWarning() << "Failed to find SwitchableOutput service item for:" << uid;
		}
	}

	emit serviceUidChanged();
	emit outputIdChanged();
	emit uidChanged();
}

QString SwitchableOutput::outputId() const
{
	return m_outputItem ? m_outputItem->id() : QString();
}

QString SwitchableOutput::serviceUid() const
{
	return m_serviceUid;
}

QString SwitchableOutput::formattedName() const
{
	return m_formattedName;
}

int SwitchableOutput::state() const
{
	// Default state is 0 (off)
	return m_stateItem ? m_stateItem->getValue().toInt() : 0;
}

int SwitchableOutput::status() const
{
	// Default status is 0 (off)
	return m_statusItem ? m_statusItem->getValue().toInt() : 0;
}

qreal SwitchableOutput::dimming() const
{
	return m_dimmingItem ? m_dimmingItem->getValue().value<qreal>() : 0;
}

int SwitchableOutput::type() const
{
	// Default type is -1
	bool ok = false;
	const int t = m_typeItem ? m_typeItem->getValue().toInt(&ok) : -1;
	return ok ? t : -1;
}

QString SwitchableOutput::group() const
{
	return m_groupItem ? m_groupItem->getValue().toString() : QString();
}

bool SwitchableOutput::allowedInGroupModel() const
{
	return m_allowedInGroupModel;
}

int SwitchableOutput::unitType() const
{
	return m_unitType;
}

int SwitchableOutput::decimals() const
{
	return m_decimals;
}

QString SwitchableOutput::unitText() const
{
	return m_unitText;
}

void SwitchableOutput::setState(int state)
{
	if (m_stateItem) {
		m_stateItem->setValue(state);
	}
}

void SwitchableOutput::setDimming(qreal dimming)
{
	if (m_dimmingItem) {
		m_dimmingItem->setValue(dimming);
	}
}

void SwitchableOutput::setType(int type)
{
	if (m_typeItem) {
		m_typeItem->setValue(type);
		updateAllowedInGroupModel();
		emit typeChanged();
	}
}

void SwitchableOutput::setTypeFromVariant(const QVariant &typeValue)
{
	setType(typeValue.isValid() ? typeValue.toInt() : -1);
}

void SwitchableOutput::setUnit(const QVariant &unitValue)
{
	const QString unitText = unitValue.toString();
	int unitType = Enums::Units_None;

	// get the base unit
	if (unitText == QStringLiteral("\\S")) {
		unitType = Enums::Units_Speed_MetresPerSecond;
	} else if (unitText == QStringLiteral("\\T")) {
		unitType = Enums::Units_Temperature_Celsius;
	} else if (unitText == QStringLiteral("\\V")) {
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

void SwitchableOutput::setDecimals(const QVariant &decimalsVariant)
{
	bool valid = false;
	const int decimals = decimalsVariant.toInt(&valid);
	m_rawDecimals = valid ? decimals : -1;
	updateDecimals();
}

void SwitchableOutput::updateDecimalsFromStepSize(const QVariant &stepSizeVariant)
{
	m_stepSizeString = stepSizeVariant.toString();
	updateDecimals();
}

void SwitchableOutput::updateDecimals()
{
	// If /Decimals is set, use that. Otherwise, use the number of decimals found in the /StepSize
	// value (which may be zero).
	int decimalCount = 0;
	if (m_rawDecimals >= 0) {
		decimalCount = m_rawDecimals;
	} else {
		const int separatorIndex = m_stepSizeString.indexOf('.');
		if (separatorIndex >= 0) {
			decimalCount = m_stepSizeString.length() - separatorIndex - 1;
		}
	}
	if (decimalCount != m_decimals) {
		m_decimals = decimalCount;
		emit decimalsChanged();
	}
}

void SwitchableOutput::updateAllowedInGroupModel()
{
	// Output is allowed in the group model if all these conditions are true:
	// - ShowUIControl is not set, or is set to 1
	// - Type is a UI-controllable type
	// - If this is a system relay, it is only allowed if it is set as a manual relay
	const QVariant showUIControl = m_showUIControlItem ? m_showUIControlItem->getValue() : QVariant();
	const int typeInt = type();
	const bool allowed = (!showUIControl.isValid() || showUIControl.toInt() == 1)
			&& (typeInt >= 0 && typeInt != Enums::SwitchableOutput_Type_Slave)
			&& (!m_relayFunctionItem || m_relayFunctionItem->getValue().toInt() == Enums::Relay_Function_Manual);
	if (allowed != m_allowedInGroupModel) {
		m_allowedInGroupModel = allowed;
		emit allowedInGroupModelChanged();
	}
}

void SwitchableOutput::updateFormattedName()
{
	QString newFormattedName;
	const QString customName = m_customNameItem ? m_customNameItem->getValue().toString() : QString();

	if (customName.length() > 0) {
		newFormattedName = customName;
	} else if (m_groupItem && m_groupItem->getValue().toString().length() > 0) {
		// When the output is in a named group (where it might be in the same group as outputs
		// from other devices) then use a name that identifies the source device/service.
		QString prefix;
		if (BaseDevice::serviceTypeFromUid(m_serviceUid) == QStringLiteral("system")) {
			//% "GX device relays"
			prefix = qtTrId("switchableoutput_gx_device_relays");
		} else if (m_device) {
			prefix = m_device->customName().length() > 0
					? m_device->customName()
					: QStringLiteral("%1 (%2)").arg(m_device->productName()).arg(m_device->deviceInstance());
		}
		newFormattedName = QStringLiteral("%1 | %2").arg(prefix).arg(m_nameItem ? m_nameItem->getValue().toString() : QString());
	} else {
		// When the output is in the default group for the device, instead of in a named group,
		// then the /Name can be used directly.
		newFormattedName = m_nameItem ? m_nameItem->getValue().toString() : QString();
	}

	if (m_formattedName != newFormattedName) {
		m_formattedName = newFormattedName;
		emit formattedNameChanged();
	}
}
