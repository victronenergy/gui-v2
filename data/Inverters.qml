/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "inverter"
	}

	function addInverter(inverter) {
		model.addObject(inverter)
	}

	function removeInverter(inverter) {
		model.removeObject(inverter.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function inverterModeToText(m) {
		switch (m) {
		case VenusOS.Inverters_Mode_On:
			return CommonWords.onOrOff(1)
		case VenusOS.Inverters_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("inverters_mode_charger_only")
		case VenusOS.Inverters_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("inverters_mode_inverter_only")
		case VenusOS.Inverters_Mode_Off:
			return CommonWords.onOrOff(0)
		default:
			return ""
		}
	}

	Component.onCompleted: Global.inverters = root
}
