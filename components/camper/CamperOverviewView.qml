/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

/*
	The RV illustration, for a given set of system values.

	This has no backend dependencies. The owner provides the values, and may replace the text.
*/
Item {
	id: root

	property int colorScheme: 0  // 0: light, 1: dark
	property CamperTheme theme: CamperTheme {
		colors.dark: root.colorScheme === 1
	}

	// The raw system values, which CamperState interprets. See CamperState for their meaning.
	property alias activeInputSource: rvState.activeInputSource
	property alias acInputSources: rvState.acInputSources
	property alias systemState: rvState.systemState
	property alias inverterChargerPower: rvState.inverterChargerPower
	property alias alternatorStates: rvState.alternatorStates
	property alias lowSocAlarm: rvState.lowSocAlarm
	property alias veBusLowBatteryAlarm: rvState.veBusLowBatteryAlarm
	property alias solarDeviceCount: rvState.solarDeviceCount
	property alias activeInputPower: rvState.activeInputPower
	property alias generatorPower: rvState.generatorPower
	property alias solarPower: rvState.solarPower
	property alias alternatorPower: rvState.alternatorPower
	property alias batteryPower: rvState.batteryPower
	property alias dcLoadsPower: rvState.dcLoadsPower
	property alias acLoadsPower: rvState.acLoadsPower
	property real batterySoc: NaN

	// Translated defaults, which a host may replace with its own, e.g. gui-v2's CommonWords.
	//% "Shore"
	property string shoreTitle: qsTrId("camperoverviewview_shore")
	//% "Grid"
	property string gridTitle: qsTrId("camperoverviewview_grid")
	//% "PV"
	property string solarTitle: qsTrId("camperoverviewview_solar_pv")
	//% "Generator"
	property string generatorTitle: qsTrId("camperoverviewview_generator")
	//% "Alternator"
	property string alternatorTitle: qsTrId("camperoverviewview_alternator")
	//% "DC"
	property string dcLoadsTitle: qsTrId("camperoverviewview_dc_loads")
	//% "AC"
	property string acLoadsTitle: qsTrId("camperoverviewview_ac_loads")
	//% "AC off"
	property string acOffTitle: qsTrId("camperoverviewview_ac_off")
	//% "AC cut"
	property string acCutTitle: qsTrId("camperoverviewview_ac_cut")

	// Formats a finite power in Watts as { number, unit }. This default follows gui-v2's Units for
	// Watts, for hosts that have no Units: whole Watts below 10 kW, else kW with two decimals.
	property var powerFormatter: function(watts) {
		if (Math.abs(watts) >= 10000) {
			return { number: (watts / 1000).toFixed(2), unit: "kW" }
		}
		const rounded = Math.round(watts)
		return { number: (rounded === 0 ? 0 : rounded).toString(), unit: "W" }
	}

	CamperState {
		id: rvState
	}

	CamperOverviewScene {
		anchors.fill: parent
		camperState: rvState
		theme: root.theme
		powerFormatter: root.powerFormatter
		gridShoreTitle: rvState.gridInput ? root.gridTitle : root.shoreTitle
		solarTitle: root.solarTitle
		generatorTitle: root.generatorTitle
		alternatorTitle: root.alternatorTitle
		dcLoadsTitle: root.dcLoadsTitle
		acLoadsTitle: root.acLoadsTitle
		acOffTitle: root.acOffTitle
		acCutTitle: root.acCutTitle
		batterySoc: root.batterySoc
	}
}
