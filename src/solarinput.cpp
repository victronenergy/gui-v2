/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

#include "solarinput.h"

#include <QQmlInfo>

using namespace Victron::VenusOS;

SolarInput::SolarInput(const QString &serviceUid, const QString &group, QObject *parent)
	: QObject(parent)
	, m_serviceUid(serviceUid)
	, m_group(group)
{
}

QString SolarInput::serviceUid() const
{
	return m_serviceUid;
}

QString SolarInput::serviceType() const
{
	return BaseDevice::serviceTypeFromUid(m_serviceUid);
}

QString SolarInput::group() const
{
	return m_group;
}

bool SolarInput::isEnabled() const
{
	return m_enabled;
}

void SolarInput::setEnabled(const QVariant &enabled)
{
	// If variant is not valid, then assume enabled=true, to preserve compatibility with older
	// devices that do not have /Enabled values.
	const bool value = !enabled.isValid() || enabled.toInt() == 1;
	if (m_enabled != value) {
		m_enabled = value;
		emit enabledChanged();
	}
}

QString SolarInput::name() const
{
	return m_name;
}

void SolarInput::setName(const QString &name)
{
	if (m_name != name) {
		m_name = name;
		emit nameChanged();
	}
}

qreal SolarInput::todaysYield() const
{
	return m_todaysYield;
}

void SolarInput::setTodaysYield(const QVariant &todaysYield)
{
	const qreal value = todaysYield.isValid() ? todaysYield.value<qreal>() : qQNaN();
	if (m_todaysYield != value) {
		m_todaysYield = value;
		emit todaysYieldChanged();
	}
}

qreal SolarInput::power() const
{
	return m_power;
}

void SolarInput::setPower(const QVariant &power)
{
	const qreal value = power.isValid() ? power.value<qreal>() : qQNaN();
	if (m_power != value) {
		m_power = value;
		emit powerChanged();
	}
}

qreal SolarInput::current() const
{
	return m_current;
}

void SolarInput::setCurrent(const QVariant &current)
{
	const qreal value = current.isValid() ? current.value<qreal>() : qQNaN();
	if (m_current != value) {
		m_current = value;
		emit currentChanged();
	}
}

qreal SolarInput::voltage() const
{
	return m_voltage;
}

void SolarInput::setVoltage(const QVariant &voltage)
{
	const qreal value = voltage.isValid() ? voltage.value<qreal>() : qQNaN();
	if (m_voltage != value) {
		m_voltage = value;
		emit voltageChanged();
	}
}

TrackerSolarInput::TrackerSolarInput(Device *device, bool isSingleTrackerDevice, int trackerIndex, QObject *parent)
	: SolarInput(device->serviceUid(), QStringLiteral("generic"), parent)
	, m_device(device)
	, m_trackerIndex(trackerIndex)
	, m_isSingleTrackerDevice(isSingleTrackerDevice)
{
	Q_ASSERT(device);

	if (VeQItem *serviceItem = device->serviceItem()) {
		m_daysAvailableItem = serviceItem->itemGetOrCreate(QStringLiteral("History/Overall/DaysAvailable"));
		if (m_daysAvailableItem) {
			connect(m_daysAvailableItem, &VeQItem::valueChanged, this, &TrackerSolarInput::daysAvailableChanged);
			daysAvailableChanged(m_daysAvailableItem->getValue());
		}

		if (isSingleTrackerDevice) {
			m_powerItem = serviceItem->itemGetOrCreate(QStringLiteral("Yield/Power"));
			m_voltageItem = serviceItem->itemGetOrCreate(QStringLiteral("Pv/V"));
		} else {
			m_powerItem = serviceItem->itemGetOrCreate(QStringLiteral("Pv/%1/P").arg(trackerIndex));
			m_voltageItem = serviceItem->itemGetOrCreate(QStringLiteral("Pv/%1/V").arg(trackerIndex));
		}
		if (m_powerItem) {
			updatePower(m_powerItem->getValue());
			connect(m_powerItem, &VeQItem::valueChanged, this, &TrackerSolarInput::updatePower);
		}
		if (m_voltageItem) {
			updateVoltage(m_voltageItem->getValue());
			connect(m_voltageItem, &VeQItem::valueChanged, this, &TrackerSolarInput::updateVoltage);
		}

		m_enabledItem = serviceItem->itemGetOrCreate(QStringLiteral("Pv/%1/Enabled").arg(trackerIndex));
		if (m_enabledItem) {
			setEnabled(m_enabledItem->getValue());
			connect(m_enabledItem, &VeQItem::valueChanged, this, &TrackerSolarInput::setEnabled);
		}

		m_nameItem = serviceItem->itemGetOrCreate(QStringLiteral("Pv/%1/Name").arg(trackerIndex));
		if (m_nameItem) {
			connect(m_nameItem, &VeQItem::valueChanged, this, &TrackerSolarInput::updateName);
		}

		// Update name using the device name and/or the tracker name.
		connect(device, &Device::nameChanged, this, &TrackerSolarInput::updateName);
		updateName();
	}
}

bool TrackerSolarInput::isEnabledTracker(VeQItem *serviceItem, int trackerIndex)
{
	if (!serviceItem) {
		return false;
	}

	if (VeQItem *enabledItem = serviceItem->itemGet(QStringLiteral("Pv/%1/Enabled").arg(trackerIndex))) {
		const QVariant enabledValue = enabledItem->getValue();
		if (enabledValue.isValid()) {
			return enabledValue.toInt() == 1;
		}
	}

	// If /Enabled is not present, assume the tracker is valid, as older devices do not have
	// this value.
	return true;
}

void TrackerSolarInput::daysAvailableChanged(QVariant value)
{
	if (!m_todaysYieldItem && value.toInt() > 0 && m_daysAvailableItem) {
		if (VeQItem *overallItem = m_daysAvailableItem->itemParent()) {
			if (VeQItem *historyItem = overallItem->itemParent()) {
				if (m_isSingleTrackerDevice) {
					m_todaysYieldItem = historyItem->itemGetOrCreate(QStringLiteral("Daily/0/Yield"));
				} else {
					m_todaysYieldItem = historyItem->itemGetOrCreate(QStringLiteral("Daily/0/Pv/%1/Yield").arg(m_trackerIndex));
				}
			}
		}
		if (m_todaysYieldItem) {
			connect(m_todaysYieldItem, &VeQItem::valueChanged, this, &TrackerSolarInput::setTodaysYield);
		}
	}
	setTodaysYield(m_todaysYieldItem ? m_todaysYieldItem->getValue() : QVariant());
}

void TrackerSolarInput::updateName()
{
	if (!m_device) {
		return;
	}

	const QString trackerName = m_nameItem ? m_nameItem->getValue().toString() : QString();
	if (trackerName.length() > 0) {
		setName(QStringLiteral("%1-%2").arg(m_device->name()).arg(trackerName));
	} else if (!m_isSingleTrackerDevice) {
		setName(QStringLiteral("%1-#%2").arg(m_device->name()).arg(m_trackerIndex + 1));
	} else {
		setName(m_device->name());
	}
}

void TrackerSolarInput::updatePower(const QVariant &value)
{
	setPower(value);
	updateCurrent();
}

void TrackerSolarInput::updateVoltage(const QVariant &value)
{
	setVoltage(value);
	updateCurrent();
}

void TrackerSolarInput::updateCurrent()
{
	// Trackers do not have current values, so calculate it manually.
	if (!qIsNaN(m_power) && !qIsNaN(m_voltage) && m_voltage != 0) {
		setCurrent(m_power / m_voltage);
	} else {
		setCurrent(qQNaN());
	}
}

PvInverterSolarInput::PvInverterSolarInput(Device *device, QObject *parent)
	: SolarInput(device->serviceUid(), QStringLiteral("pvinverter"), parent)
{
	Q_ASSERT(device);

	if (VeQItem *serviceItem = device->serviceItem()) {
		m_acItem = serviceItem->itemGetOrCreate(QStringLiteral("Ac"));
		if (m_acItem) {
			for (auto it = m_acItem->itemChildren().begin(); it != m_acItem->itemChildren().end(); ++it) {
				if (isPhaseId(it.key())) {
					addPhase(it.value());
				}
			}
		}
		connect(m_acItem, &VeQItem::childAdded, this, &PvInverterSolarInput::acChildAdded);
		connect(m_acItem, &VeQItem::childAboutToBeRemoved, this, &PvInverterSolarInput::acChildAboutToBeRemoved);

		m_powerItem = serviceItem->itemGetOrCreate(QStringLiteral("Ac/Power"));
		if (m_powerItem) {
			setPower(m_powerItem->getValue());
			connect(m_powerItem, &VeQItem::valueChanged, this, &PvInverterSolarInput::setPower);
		}
	}

	setName(device->name());
	connect(device, &Device::nameChanged, this, [this, device]() {
		setName(device->name());
	});

	updateSinglePhaseValues();
}

bool PvInverterSolarInput::isPhaseId(const QString &childId) const
{
	// Phases are L1, L2, L3
	return childId == QStringLiteral("L1")
			|| childId == QStringLiteral("L2")
			|| childId == QStringLiteral("L3");
}

void PvInverterSolarInput::acChildAdded(VeQItem *child)
{
	Q_ASSERT(child);
	if (isPhaseId(child->id())) {
		addPhase(child);
		updateSinglePhaseValues();
	}
}

void PvInverterSolarInput::acChildAboutToBeRemoved(VeQItem *child)
{
	Q_ASSERT(child);
	if (isPhaseId(child->id())) {
		m_phases.remove(child->id());
		updateSinglePhaseValues();
	}
}

void PvInverterSolarInput::addPhase(VeQItem *phaseItem)
{
	Q_ASSERT(phaseItem);

	const QString phaseName = phaseItem->id();
	m_phases.insert(phaseName, AcPhase{});

	if (VeQItem *currentItem = phaseItem->itemGetOrCreate(QStringLiteral("Current"))) {
		const QVariant value = currentItem->getValue();
		m_phases[phaseName].current = value.isValid() ? value.value<qreal>() : qQNaN();
		connect(currentItem, &VeQItem::valueChanged, this, [this, phaseName](QVariant value) {
			if (auto it = m_phases.find(phaseName); it != m_phases.end()) {
				it.value().current = value.isValid() ? value.value<qreal>() : qQNaN();
				updateSinglePhaseValues();
			}
		});
	}
	if (VeQItem *voltageItem = phaseItem->itemGetOrCreate(QStringLiteral("Voltage"))) {
		const QVariant value = voltageItem->getValue();
		m_phases[phaseName].voltage = value.isValid() ? value.value<qreal>() : qQNaN();
		connect(voltageItem, &VeQItem::valueChanged, this, [this, phaseName](QVariant value) {
			if (auto it = m_phases.find(phaseName); it != m_phases.end()) {
				it.value().voltage = value.isValid() ? value.value<qreal>() : qQNaN();
				updateSinglePhaseValues();
			}
		});
	}
}

void PvInverterSolarInput::updateSinglePhaseValues()
{
	// If there is only one valid phase, use the current and voltage from that phase.
	// If there are multiple phases with valid current and voltage, the overall current and voltage
	// are set to NaN, since current and voltage from different phases cannot be summed together.
	qreal singlePhaseCurrent = qQNaN();
	qreal singlePhaseVoltage = qQNaN();

	for (const AcPhase &phase : std::as_const(m_phases)) {
		if (!qIsNaN(phase.current) || !qIsNaN(phase.voltage)) {
			// The current and/or phase are valid.
			if (qIsNaN(singlePhaseCurrent) && qIsNaN(singlePhaseVoltage)) {
				// No other phase has been seen with valid data, so use these as the current/voltage
				// values for  this PV inverter.
				singlePhaseCurrent = phase.current;
				singlePhaseVoltage = phase.voltage;
			} else {
				// Another phase already has valid data, so there must be multiple valid phases for
				// the device, so clear the single-phase values.
				singlePhaseCurrent = qQNaN();
				singlePhaseVoltage = qQNaN();
				break;
			}
		}
	}

	setCurrent(singlePhaseCurrent);
	setVoltage(singlePhaseVoltage);
}
