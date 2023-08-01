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

	property var system: SystemBattery {}

	readonly property var daysHoursMinutesToGo: system.timeToGo ? Utils.decomposeDurationDaysHoursMinutes(system.timeToGo) : NaN

	function addBattery(battery) {
		model.addObject(battery)
	}

	function removeBattery(battery) {
		model.removeObject(battery.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function batteryIcon(battery) {
		return isNaN(battery.power) || battery.power === 0 ? "/images/battery.svg"
			: (battery.power > 0 ? "/images/battery_charging.svg" : "/images/battery_discharging.svg")
	}

	function batteryMode(battery) {
		return isNaN(battery.power) || battery.power === 0 ? VenusOS.Battery_Mode_Idle
			: (battery.power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)
	}

	Component.onCompleted: Global.batteries = root
}
