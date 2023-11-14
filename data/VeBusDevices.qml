/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "veBusDevices"
	}

	property real totalNominalInverterPower: NaN

	function addVeBusDevice(veBusDevice) {
		if (model.addDevice(veBusDevice)) {
			refreshNominalInverterPower()
		}
	}

	function removeVeBusDevice(veBusDevice) {
		return model.removeDevice(veBusDevice.serviceUid)
	}

	function refreshNominalInverterPower() {
		let total = NaN
		for (let i = 0; i < model.count; ++i) {
			const veBusDevice = model.deviceAt(i)
			const value = veBusDevice.nominalInverterPower
			if (!isNaN(value)) {
				total = isNaN(total) ? value : total + value
			}
		}
		totalNominalInverterPower = total
	}

	function reset() {
		model.clear()
	}

	function modeToText(m) {
		switch (m) {
		case VenusOS.VeBusDevice_Mode_On:
			return CommonWords.onOrOff(1)
		case VenusOS.VeBusDevice_Mode_ChargerOnly:
			//% "Charger only"
			return qsTrId("veBusDevices_mode_charger_only")
		case VenusOS.VeBusDevice_Mode_InverterOnly:
			//% "Inverter only"
			return qsTrId("veBusDevices_mode_inverter_only")
		case VenusOS.VeBusDevice_Mode_Off:
			return CommonWords.onOrOff(0)
		default:
			return ""
		}
	}

	Component.onCompleted: Global.veBusDevices = root
}
