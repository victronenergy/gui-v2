/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The RV illustration, for a given set of system values.

	This has no backend dependencies. The owner provides the values and the translated text.
*/
Item {
	id: root

	property int colorScheme: 0

	property alias activeInputSource: stateModel.activeInputSource
	property alias systemState: stateModel.systemState
	property alias inverterChargerPower: stateModel.inverterChargerPower
	property alias alternatorState: stateModel.alternatorState
	property alias lowSocAlarm: stateModel.lowSocAlarm
	property alias veBusLowBatteryAlarm: stateModel.veBusLowBatteryAlarm
	property alias solarPresent: stateModel.solarPresent
	property alias generatorPresent: stateModel.generatorPresent
	readonly property alias state: stateModel

	property real activeInputPower: NaN
	property real generatorPower: NaN
	property real solarPower: NaN
	property real alternatorPower: NaN
	property real batteryPower: NaN
	property real batterySoc: NaN
	property real dcLoadsPower: NaN
	property real acLoadsPower: NaN

	property string shoreTitle: "Shore"
	property string gridTitle: "Grid"
	property string solarTitle: "PV"
	property string generatorTitle: "Generator"
	property string alternatorTitle: "Alternator"
	property string dcLoadsTitle: "DC"
	property string acLoadsTitle: "AC"

	CamperStateModel {
		id: stateModel
	}

	CamperOverviewScene {
		anchors.fill: parent

		colorScheme: root.colorScheme
		scenario: stateModel.scenario
		lowBatteryAlarm: stateModel.lowBatteryAlarm
		acOutputCut: stateModel.acOutputCut

		gridShoreTitle: stateModel.activeInputSource === stateModel.sourceGrid ? root.gridTitle : root.shoreTitle
		gridShoreIsShore: stateModel.activeInputSource !== stateModel.sourceGrid
		solarTitle: root.solarTitle
		generatorTitle: root.generatorTitle
		alternatorTitle: root.alternatorTitle
		dcLoadsTitle: root.dcLoadsTitle
		acLoadsTitle: root.acLoadsTitle

		solar: stateModel.solarPresent
		generator: stateModel.generatorPresent

		gridShorePower: stateModel.externalAcInput ? root.activeInputPower : NaN
		generatorPower: root.generatorPower
		solarPower: root.solarPower
		batteryPower: root.batteryPower
		batterySoc: root.batterySoc
		alternatorPower: root.alternatorPower
		dcLoadsPower: root.dcLoadsPower
		acLoadsPower: root.acLoadsPower
	}
}
