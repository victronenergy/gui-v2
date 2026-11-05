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
*/
QtObject {
	id: root

	// The values of com.victronenergy.system/Ac/ActiveIn/Source
	readonly property int sourceNotAvailable: 0
	readonly property int sourceGrid: 1
	readonly property int sourceGenerator: 2
	readonly property int sourceShore: 3
	readonly property int sourceInverting: 240

	readonly property int scenarioCharging: 0
	readonly property int scenarioDriving: 1
	readonly property int scenarioParking: 2
	readonly property int scenarioOffGrid: 3

	// Battery power at or above this value (in Watts) means the battery is being charged.
	readonly property real chargingPowerThreshold: 30

	property int activeInputSource: sourceNotAvailable
	property bool acInputConnected: false
	property int alternatorState: -1 // com.victronenergy.alternator/State, or -1 if there is none
	property real batteryPower: NaN
	property int lowSocAlarm: 0 // Alarms/LowSoc: 0 = inactive, 1 = warning, 2 = alarm

	readonly property bool externalAcInput: activeInputSource === sourceShore || activeInputSource === sourceGrid
	readonly property bool shoreCharging: externalAcInput && batteryPower >= chargingPowerThreshold
	readonly property bool passThrough: externalAcInput && !shoreCharging
	readonly property bool generatorInput: activeInputSource === sourceGenerator
	readonly property bool driving: (alternatorState >= 3 && alternatorState <= 7) || alternatorState === 252
	readonly property bool parked: alternatorState === 0 && activeInputSource === sourceInverting
	readonly property bool offGrid: !acInputConnected
	readonly property bool lowBatteryAlarm: lowSocAlarm === 2

	readonly property int scenario: externalAcInput ? scenarioCharging
			: driving ? scenarioDriving
			: parked || generatorInput ? scenarioParking
			: scenarioOffGrid
}
