/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "input"
	}

	function addInput(input) {
		model.addObject(input)
	}

	function removeInput(input) {
		model.removeObject(input.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.environmentInputs = root
}
