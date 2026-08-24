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

	property int activeInputSource: _inputSourceNotAvailable
	property real activeInputPower: NaN
	property real solarDcPower: NaN
	property real solarAcL1Power: NaN
	property real solarAcL2Power: NaN
	property real solarAcL3Power: NaN
	property real batteryPower: NaN
	property real batterySoc: NaN
	property real alternatorPower: NaN
	property real dcLoadsPower: NaN
	property real acLoadsL1Power: NaN
	property real acLoadsL2Power: NaN
	property real acLoadsL3Power: NaN

	readonly property int _activeInputSource: Number(activeInputSource)
	readonly property bool _gridOrShoreActive: _activeInputSource === _inputSourceGrid
			|| _activeInputSource === _inputSourceShore
	readonly property bool _generatorActive: _activeInputSource === _inputSourceGenerator

	readonly property real _movingAlternatorThreshold: 50
	readonly property int _scenario: _gridOrShoreActive ? scenarioCharging
			: alternatorPower > _movingAlternatorThreshold ? scenarioDriving
			: _generatorActive ? scenarioParking
			: scenarioOffGrid

	readonly property real gridShorePower: _gridOrShoreActive && isFinite(activeInputPower) ? activeInputPower
			: NaN
	readonly property real generatorPower: _generatorActive && isFinite(activeInputPower) ? activeInputPower
			: NaN
	readonly property real solarPower: _sumPowerValues([
		solarDcPower,
		solarAcL1Power,
		solarAcL2Power,
		solarAcL3Power
	])
	readonly property real acLoadsPower: _sumPowerValues([
		acLoadsL1Power,
		acLoadsL2Power,
		acLoadsL3Power
	])
	readonly property bool _shoreActive: _activeInputSource === _inputSourceShore

	//: "Shore"
	readonly property string _gridShoreTitle: _activeInputSource === _inputSourceShore ? qsTrId("camper_card_shore")
			//: "Grid"
			: _activeInputSource === _inputSourceGrid ? qsTrId("camper_card_grid")
			//: "Grid/Shore"
			: qsTrId("camper_card_grid_shore")
	//: "Charging"
	readonly property string _scenarioText: _scenario === scenarioCharging ? qsTrId("camper_scenario_charging")
			//: "Driving"
			: _scenario === scenarioDriving ? qsTrId("camper_scenario_driving")
			//: "Parking"
			: _scenario === scenarioParking ? qsTrId("camper_scenario_parking")
			//: "Off-grid"
			: qsTrId("camper_scenario_offgrid")
	//% "Solar PV"
	readonly property string _solarTitle: qsTrId("camper_card_solar_pv")
	//% "Generator"
	readonly property string _generatorTitle: qsTrId("camper_card_generator")
	//% "Battery"
	readonly property string _batteryTitle: qsTrId("camper_card_battery")
	//% "Alternator"
	readonly property string _alternatorTitle: qsTrId("camper_card_alternator")
	//% "DC Loads"
	readonly property string _dcLoadsTitle: qsTrId("camper_card_dc_loads")
	//% "AC Loads"
	readonly property string _acLoadsTitle: qsTrId("camper_card_ac_loads")

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
		scenario: root._scenario
		scenarioText: root._scenarioText
		gridShoreTitle: root._gridShoreTitle
		gridShoreIsShore: root._shoreActive
		solarTitle: root._solarTitle
		generatorTitle: root._generatorTitle
		batteryTitle: root._batteryTitle
		alternatorTitle: root._alternatorTitle
		dcLoadsTitle: root._dcLoadsTitle
		acLoadsTitle: root._acLoadsTitle
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
