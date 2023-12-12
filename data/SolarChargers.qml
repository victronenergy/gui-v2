/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// Model of all solar chargers
	property DeviceModel model: DeviceModel {
		modelId: "solarChargers"
	}

	function addCharger(charger) {
		model.addDevice(charger)
	}

	function removeCharger(charger) {
		model.removeDevice(charger.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function chargerStateToText(state) {
		switch (state) {
		case Enums.SolarCharger_State_Off:
			//% "Off"
			return qsTrId("solarchargers_state_off")
		case Enums.SolarCharger_State_Fault:
			//% "Fault"
			return qsTrId("solarchargers_state_fault")
		case Enums.SolarCharger_State_Buik:
			//% "Bulk"
			return qsTrId("solarchargers_state_bulk")
		case Enums.SolarCharger_State_Absorption:
			//% "Absorption"
			return qsTrId("solarchargers_state_absorption")
		case Enums.SolarCharger_State_Float:
			//% "Float"
			return qsTrId("solarchargers_state_float")
		case Enums.SolarCharger_State_Storage:
			//% "Storage"
			return qsTrId("solarchargers_state_storage")
		case Enums.SolarCharger_State_Equalize:
			//% "Equalize"
			return qsTrId("solarchargers_state_equalize")
		case Enums.SolarCharger_State_ExternalControl:
			//% "External control"
			return qsTrId("solarchargers_state_external control")
		default:
			return ""
		}
	}

	function chargerErrorToText(errorCode) {
		// TODO when BMS and charger errors are available in veutil
		return ""
	}

	Component.onCompleted: Global.solarChargers = root
}
