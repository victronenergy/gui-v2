/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "battery"
	}
	property var first: model.firstObject

	function addBattery(battery) {
		model.addObject(battery)
	}

	function removeBattery(battery) {
		model.removeObject(battery.serviceUid)
	}

	function reset() {
		model.clear()
	}

	Component.onCompleted: Global.batteries = root
}
