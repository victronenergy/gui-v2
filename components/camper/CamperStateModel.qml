/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml

/*
	Derives the state of an RV from its system values, as described in the "Custom Illustrations"
	section of the UI design document.

	This has no backend dependencies, so that it can be used by both the gui-v2 page, which reads
	the values from the backend, and the standalone app, which is given them by the hosting page.

	The states are not mutually exclusive: e.g. a low battery alarm can exist alongside any other
	state. The 'scenario' value selects which illustration background to show, and so it does have
	exactly one value at a time.

	There is no parked state: an RV that is neither on shore power nor driving is off-grid, whether
	or not a generator is running.
*/
QtObject {
	id: root

	// The values of com.victronenergy.system/Ac/ActiveIn/Source
	readonly property int sourceNotAvailable: 0
	readonly property int sourceGrid: 1
	readonly property int sourceGenerator: 2
	readonly property int sourceShore: 3
	readonly property int sourceInverting: 240

	// The values of com.victronenergy.system/SystemState/State that the states depend on
	readonly property int systemStateBulk: 3
	readonly property int systemStateAbsorption: 4
	readonly property int systemStateFloat: 5
	readonly property int systemStatePassthru: 8
	readonly property int systemStateExternalControl: 252

	// The values of the /Alarms/* paths
	readonly property int alarmOk: 0
	readonly property int alarmWarning: 1
	readonly property int alarmAlarm: 2

	readonly property int scenarioCharging: 0
	readonly property int scenarioDriving: 1
	readonly property int scenarioOffGrid: 2

	// Under external control, the inverter/charger can be in any mode, and the system state does not
	// say which. Inverter/charger DC power at or above this value (in Watts) then means that it is
	// charging the battery.
	readonly property real chargingPowerThreshold: 30

	property int activeInputSource: sourceNotAvailable  // system/Ac/ActiveIn/Source
	property int systemState: -1                       // system/SystemState/State, or -1 if invalid
	property real inverterChargerPower: NaN             // system/Dc/InverterCharger/Power
	property int alternatorState: -1                   // alternator/State, or -1 if there is none
	property int lowSocAlarm: alarmOk                   // /Alarms/LowSoc of the active battery
	property int veBusLowBatteryAlarm: alarmOk          // vebus/Alarms/LowBattery
	property bool solarPresent: false                   // whether there is a solar charger
	property bool generatorPresent: false               // whether any system/Ac/In/x/Source is 2

	// The design document only describes shore. Grid is treated the same way, as on the overview.
	readonly property bool externalAcInput: activeInputSource === sourceShore || activeInputSource === sourceGrid
	readonly property bool _externalControl: systemState === systemStateExternalControl

	readonly property bool shoreCharging: externalAcInput && (_externalControl
			? isFinite(inverterChargerPower) && inverterChargerPower >= chargingPowerThreshold
			: systemState === systemStateBulk
				|| systemState === systemStateAbsorption
				|| systemState === systemStateFloat)
	readonly property bool passThrough: externalAcInput && (_externalControl
			? isFinite(inverterChargerPower) && inverterChargerPower < chargingPowerThreshold
			: systemState === systemStatePassthru)
	readonly property bool driving: (alternatorState >= 3 && alternatorState <= 7) || alternatorState === 252
	readonly property bool offGrid: !externalAcInput
	readonly property bool solarOnly: solarPresent && !generatorPresent
	readonly property bool lowBatteryAlarm: lowSocAlarm === alarmAlarm

	// The inverter/charger stops inverting on its own low battery alarm, which is not the same as
	// the battery's low state of charge alarm. There may be more reasons for the AC output to be
	// cut; these are still to be defined.
	readonly property bool acOutputCut: veBusLowBatteryAlarm === alarmAlarm

	readonly property int scenario: externalAcInput ? scenarioCharging
			: driving ? scenarioDriving
			: scenarioOffGrid
}
