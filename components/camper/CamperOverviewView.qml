/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Item {
	id: root

	readonly property int scenarioCharging: 0
	readonly property int scenarioDriving: 1
	readonly property int scenarioParking: 2
	readonly property int scenarioOffGrid: 3

	readonly property int _inputSourceNotAvailable: 0
	readonly property int _inputSourceGrid: 1
	readonly property int _inputSourceGenerator: 2
	readonly property int _inputSourceShore: 3

	property int colorScheme: 0
	property int activeInputSource: _inputSourceNotAvailable
	property bool shorePower: false

	property bool generator: true
	property bool solar: true

	property real alternatorPower: NaN
	property real generatorPower: NaN
	property real solarPower: NaN

	property real activeInputPower: NaN
	property real batteryPower: NaN
	property real batterySoc: NaN
	property real dcLoadsPower: NaN
	property real acLoadsPower: NaN

	readonly property int _activeInputSource: Number(activeInputSource)
	readonly property bool _gridOrShoreActive: shorePower
			|| _activeInputSource === _inputSourceGrid
			|| _activeInputSource === _inputSourceShore
	readonly property bool _generatorActive: generatorPower > _movingAlternatorThreshold

	readonly property real _movingAlternatorThreshold: 50
	readonly property int _scenario: _gridOrShoreActive ? scenarioCharging
			: alternatorPower > _movingAlternatorThreshold ? scenarioDriving
			: _generatorActive ? scenarioParking
			: scenarioOffGrid

	readonly property real gridShorePower: _gridOrShoreActive && isFinite(activeInputPower) ? activeInputPower
			: NaN

	//% "Shore"
	readonly property string _gridShoreTitle: _activeInputSource === _inputSourceShore ? qsTrId("camper_card_shore")
			//% "Grid"
			: _activeInputSource === _inputSourceGrid ? qsTrId("camper_card_grid")
			//% "Grid/Shore"
			: qsTrId("camper_card_grid_shore")
	//% "Charging"
	readonly property string _scenarioText: _scenario === scenarioCharging ? qsTrId("camper_scenario_charging")
			//% "Driving"
			: _scenario === scenarioDriving ? qsTrId("camper_scenario_driving")
			//% "Parking"
			: _scenario === scenarioParking ? qsTrId("camper_scenario_parking")
			//% "Off-grid"
			: qsTrId("camper_scenario_offgrid")


	function _sumPowerValues(values) {
		let total = NaN
		for (let i = 0; i < values.length; ++i) {
			if (isFinite(values[i])) {
				total = isFinite(total) ? total + values[i]
						: values[i]
			}
		}
		return total
	}

	CamperOverviewScene {
		anchors.fill: parent

		colorScheme: root.colorScheme
		scenario: root._scenario
		scenarioText: root._scenarioText

		gridShoreTitle: root._gridShoreTitle

		//% "PV"
		solarTitle: qsTrId("camper_card_solar_pv")
		//% "Generator"
		generatorTitle: qsTrId("camper_card_generator")
		//% "Battery"
		batteryTitle: qsTrId("camper_card_battery")
		//% "Alternator"
		alternatorTitle: qsTrId("camper_card_alternator")
		//% "DC"
		dcLoadsTitle: qsTrId("camper_card_dc_loads")
		//% "AC"
		acLoadsTitle: qsTrId("camper_card_ac_loads")

		gridShoreIsShore: _activeInputSource === _inputSourceShore

		shorePower: root.shorePower
		solar: root.solar
		generator: root.generator

		gridShorePower: root.gridShorePower
		generatorPower: root.generatorPower
		solarPower: root.solarPower
		batteryPower: root.batteryPower
		batterySoc: root.batterySoc
		alternatorPower: root.alternatorPower
		dcLoadsPower: root.dcLoadsPower
		acLoadsPower: root.acLoadsPower
	}
}
