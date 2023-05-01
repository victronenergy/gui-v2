/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// Model of all solar chargers
	property ListModel model: ListModel {}

	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	property real dcPower: NaN

	// Unlike for power, the AC and DC currents cannot be combined because amps for AC and DC
	// sources are on different scales. So if they are both present, the total is NaN.
	readonly property real current: (acCurrent || 0) !== 0 && (dcCurrent || 0) !== 0
			? NaN
			: (acCurrent || 0) === 0 ? dcCurrent : acCurrent
	property real acCurrent: NaN
	property real dcCurrent: NaN

	function addCharger(charger) {
		model.append({ solarCharger: charger })
	}

	function insertCharger(index, charger) {
		model.insert(index >= 0 && index < model.count ? index : model.count, { solarCharger: charger })
	}

	function removeCharger(index) {
		model.remove(index)
	}

	function reset() {
		acPower = NaN
		dcPower = NaN
		acCurrent = NaN
		dcCurrent = NaN
		model.clear()
	}

	function chargerStateToText(state) {
		switch (state) {
		case VenusOS.SolarCharger_State_Off:
			//% "Off"
			return qsTrId("solarchargers_state_off")
		case VenusOS.SolarCharger_State_Fault:
			//% "Fault"
			return qsTrId("solarchargers_state_fault")
		case VenusOS.SolarCharger_State_Buik:
			//% "Bulk"
			return qsTrId("solarchargers_state_bulk")
		case VenusOS.SolarCharger_State_Absorption:
			//% "Absorption"
			return qsTrId("solarchargers_state_absorption")
		case VenusOS.SolarCharger_State_Float:
			//% "Float"
			return qsTrId("solarchargers_state_float")
		case VenusOS.SolarCharger_State_Storage:
			//% "Storage"
			return qsTrId("solarchargers_state_storage")
		case VenusOS.SolarCharger_State_Equalize:
			//% "Equalize"
			return qsTrId("solarchargers_state_equalize")
		case VenusOS.SolarCharger_State_ExternalControl:
			//% "External control"
			return qsTrId("solarchargers_state_external control")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.solarChargers = root
}
