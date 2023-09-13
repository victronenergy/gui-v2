/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "inverter"
	}

	property real totalNominalInverterPower: NaN

	function addInverter(inverter) {
		if (model.addObject(inverter)) {
			refreshNominalInverterPower()
		}
	}

	function removeInverter(inverter) {
		return model.removeObject(inverter.serviceUid)
	}

	function refreshNominalInverterPower() {
		let total = NaN
		for (let i = 0; i < model.count; ++i) {
			const inverter = model.objectAt(i)
			const value = inverter.nominalInverterPower
			if (!isNaN(value)) {
				total = isNaN(total) ? value : total + value
			}
		}
		totalNominalInverterPower = total
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
