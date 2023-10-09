/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "generator"
	}
	property var first: model.firstObject

	function addGenerator(generator) {
		model.addObject(generator)
	}

	function removeGenerator(generator) {
		model.removeObject(generator.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.generators = root
}
