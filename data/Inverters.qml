/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property ListModel model: ListModel {}

	function addInverter(data) {
		model.append({ inverter: data })
	}

	function insertInverter(index, inverter) {
		model.insert(index >= 0 && index < model.count ? index : model.count, { inverter: inverter })
	}

	function removeInverter(index) {
		model.remove(index)
	}

	function reset() {
		model.clear()
	}

	function inverterModeToText(m) {
		switch (m) {
		case VenusOS.Inverters_Mode_On:
			return Utils.qsTrIdOnOff(1)
		case VenusOS.Inverters_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("inverter_charger_mode_charger_only")
		case VenusOS.Inverters_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("inverter_charger_mode_inverter_only")
		case VenusOS.Inverters_Mode_Off:
			return Utils.qsTrIdOnOff(0)
		default:
			return ""
		}
	}

	Component.onCompleted: Global.inverters = root
}
