/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectProperty: "battery"
	}
	property var first: model.firstObject

	readonly property var daysHoursMinutesToGo: !!first && first.timeToGo ? Utils.decomposeDurationDaysHoursMinutes(first.timeToGo) : NaN

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
