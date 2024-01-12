/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "environmentInputs"
	}

	function temperatureTypeToText(temperatureType) {
		switch (temperatureType) {
		case VenusOS.Temperature_DeviceType_Battery:
			return CommonWords.battery
		case VenusOS.Temperature_DeviceType_Fridge:
			//% "Fridge"
			return qsTrId("temperature_type_fridge")
		case VenusOS.Temperature_DeviceType_Generic:
			//% "Generic"
			return qsTrId("temperature_type_generic")
		default:
			//% "Unknown"
			return qsTrId("temperature_type_unknown")
		}
	}

	function addInput(input) {
		model.addDevice(input)
	}

	function removeInput(input) {
		model.removeDevice(input.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.environmentInputs = root
}
