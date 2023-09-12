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
