/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

/*
	Derives what the RV illustration shows from the raw system values, as described in the "Custom
	Illustrations" section of the UI design document.

	This has no backend dependencies, so that it can be used by both the gui-v2 page, which reads
	the values from the backend, and the standalone app, which reads them over MQTT. Each host only
	reads values; every rule that interprets them is here, so that both hosts show the same thing.

	The states are not mutually exclusive: e.g. a low battery alarm can exist alongside any other
	state. The 'scenario' value selects which illustration background to show, and so it does have
	exactly one value at a time.

	There is no parked state: an RV that is neither on shore power nor driving is off-grid, whether
	or not a generator is running.

	An input that the host cannot read is unknown: -1 for a state, source or alarm, and NaN for a
	power. Unknown never reads as a known state. An unknown source is not shore power, and gives
	scenarioUnknown unless the RV is driving. An unknown alarm is not an alarm, and its *Known flag
	is false, so that it is not taken for Ok.
*/
QtObject {
	id: root

	// The values of com.victronenergy.system/Ac/ActiveIn/Source and /Ac/In/<n>/Source
	readonly property int sourceUnknown: -1
	readonly property int sourceNotAvailable: 0
	readonly property int sourceGrid: 1
	readonly property int sourceGenerator: 2
	readonly property int sourceShore: 3
	readonly property int sourceInverting: 240

	// The values of com.victronenergy.system/SystemState/State that the states depend on
	readonly property int systemStateUnknown: -1
	readonly property int systemStateOff: 0
	readonly property int systemStateBulk: 3
	readonly property int systemStateAbsorption: 4
	readonly property int systemStateFloat: 5
	readonly property int systemStatePassthru: 8
	readonly property int systemStateExternalControl: 252

	// The values of the /Alarms/* paths
	readonly property int alarmUnknown: -1
	readonly property int alarmOk: 0
	readonly property int alarmWarning: 1
	readonly property int alarmAlarm: 2

	readonly property int scenarioCharging: 0
	readonly property int scenarioDriving: 1
	readonly property int scenarioOffGrid: 2
	readonly property int scenarioUnknown: 3

	// Under external control, the inverter/charger can be in any mode, and the system state does not
	// say which. Inverter/charger DC power at or above this value (in Watts) then means that it is
	// charging the battery.
	readonly property real chargingPowerThreshold: 30

	// Powers smaller than this (in Watts) are noise, as on the overview: they highlight no card and
	// draw no arrow. It is a separate rule from chargingPowerThreshold, which happens to be equal.
	readonly property real activePowerThreshold: 30

	property int activeInputSource: sourceUnknown        // system/Ac/ActiveIn/Source
	property list<int> acInputSources: []                 // system/Ac/In/<n>/Source of each AC input
	property int systemState: systemStateUnknown          // system/SystemState/State
	property real inverterChargerPower: NaN               // system/Dc/InverterCharger/Power
	property list<int> alternatorStates: []               // alternator/State of each alternator
	property int lowSocAlarm: alarmUnknown                // /Alarms/LowSoc of the active battery
	property int veBusLowBatteryAlarm: alarmUnknown       // vebus/Alarms/LowBattery
	// Solar chargers, PV inverters, and inverters or Multis with trackers, as the overview counts them.
	property int solarDeviceCount: 0

	// Powers in Watts. Battery power is positive while charging.
	property real activeInputPower: NaN
	property real generatorPower: NaN
	property real solarPower: NaN
	property real alternatorPower: NaN
	property real batteryPower: NaN
	property real dcLoadsPower: NaN
	property real acLoadsPower: NaN

	readonly property bool solarPresent: solarDeviceCount > 0
	readonly property bool generatorPresent: acInputSources.indexOf(sourceGenerator) >= 0
	readonly property bool sourceKnown: activeInputSource >= 0

	// The design document only describes shore. Grid is treated the same way, as on the overview.
	readonly property bool externalAcInput: activeInputSource === sourceShore || activeInputSource === sourceGrid
	readonly property bool gridInput: activeInputSource === sourceGrid
	readonly property bool _externalControl: systemState === systemStateExternalControl

	readonly property bool shoreCharging: externalAcInput && (_externalControl
			? isFinite(inverterChargerPower) && inverterChargerPower >= chargingPowerThreshold
			: systemState === systemStateBulk
				|| systemState === systemStateAbsorption
				|| systemState === systemStateFloat)
	readonly property bool passThrough: externalAcInput && (_externalControl
			? isFinite(inverterChargerPower) && inverterChargerPower < chargingPowerThreshold
			: systemState === systemStatePassthru)
	// Any running alternator means that the engine is running.
	readonly property bool driving: alternatorStates.some((state) => _isAlternatorRunning(state))

	readonly property bool lowBatteryAlarm: lowSocAlarm === alarmAlarm
	readonly property bool lowBatteryAlarmKnown: lowSocAlarm >= alarmOk

	// The inverter/charger stops inverting on its own low battery alarm, which is not the same as
	// the battery's low state of charge alarm. There may be more reasons for the AC output to be
	// cut; these are still to be defined.
	readonly property bool acOutputCut: veBusLowBatteryAlarm === alarmAlarm
	readonly property bool acOutputCutKnown: veBusLowBatteryAlarm >= alarmOk
	readonly property bool inverterChargerOff: systemState === systemStateOff

	readonly property int scenario: externalAcInput ? scenarioCharging
			: driving ? scenarioDriving
			: sourceKnown ? scenarioOffGrid
			: scenarioUnknown

	// The active input's power, when it is shore or grid; a generator has its own card.
	readonly property real gridShorePower: externalAcInput ? activeInputPower : NaN

	// A card is highlighted when its power is non-trivial in either direction.
	readonly property bool gridShoreActive: _isActivePower(gridShorePower)
	readonly property bool generatorActive: generatorPresent && _isActivePower(generatorPower)
	readonly property bool solarActive: _isActivePower(solarPower)
	readonly property bool alternatorActive: _isActivePower(alternatorPower)
	readonly property bool dcLoadsActive: _isActivePower(dcLoadsPower)
	readonly property bool acLoadsActive: _isActivePower(acLoadsPower)
	readonly property bool batteryActive: _isActivePower(batteryPower)
	readonly property bool _anyPowerActive: solarActive
			|| alternatorActive
			|| gridShoreActive
			|| generatorActive
			|| batteryActive
			|| acLoadsActive
			|| dcLoadsActive
	// The hub is the inverter/charger: grey when it is off, as in the design's Driving case. If
	// its state is unknown, it is shown active while any power flows.
	readonly property bool hubActive: systemState >= 0 ? !inverterChargerOff : _anyPowerActive

	// The battery widget uses the same rule as gui-v2's battery_modeFromPower(), so the RV page
	// agrees with the Brief and Overview pages.
	readonly property bool batteryCharging: isFinite(batteryPower) && batteryPower > 0
	readonly property bool batteryDischarging: isFinite(batteryPower) && batteryPower < 0

	// An arrow is drawn only when the power at both of its ends flows its way.
	readonly property bool _batteryChargingFlow: _isFlowing(batteryPower)
	readonly property bool flowGridToHub: _isFlowing(gridShorePower)
	// A genset meter reads power even while its input is not connected, so only the active input
	// feeds the hub.
	readonly property bool flowGeneratorToHub: activeInputSource === sourceGenerator && _isFlowing(generatorPower)
	readonly property bool flowSolarToBattery: _isFlowing(solarPower) && _batteryChargingFlow
	readonly property bool flowAlternatorToBattery: _isFlowing(alternatorPower) && _batteryChargingFlow
	readonly property bool flowBatteryToDc: _isFlowing(dcLoadsPower)
	readonly property bool flowHubToAc: _isFlowing(acLoadsPower) && !acOutputCut
	// With no AC input, the inverter runs from the DC side, even while solar also charges the battery.
	readonly property bool flowBatteryToHub: flowHubToAc && !flowGridToHub && !flowGeneratorToHub
	// On shore or grid, the design's "Shore charging" and "Pass-through" states decide whether the
	// charger is charging the battery.
	readonly property bool flowHubToBattery: _batteryChargingFlow
			&& (flowGridToHub ? shoreCharging : flowGeneratorToHub)

	// Whether an alternator /State means the engine is running: bulk to equalize, or external control.
	function _isAlternatorRunning(state) {
		return (state >= 3 && state <= 7) || state === 252
	}

	function _isActivePower(value) {
		return isFinite(value) && Math.abs(value) >= activePowerThreshold
	}

	function _isFlowing(value) {
		return isFinite(value) && value >= activePowerThreshold
	}
}
