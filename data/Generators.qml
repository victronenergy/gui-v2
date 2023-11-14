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
		modelId: "generators"
	}
	property var first: model.firstObject

	function addGenerator(generator) {
		model.addDevice(generator)
	}

	function removeGenerator(generator) {
		model.removeDevice(generator.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.generators = root
}
