/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "environmentInputs"
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
