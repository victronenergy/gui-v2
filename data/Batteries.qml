/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "batteries"
	}

	property var system: SystemBattery {}

	function addBattery(battery) {
		model.addDevice(battery)
	}

	function removeBattery(battery) {
		model.removeDevice(battery.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function timeToGoText(battery, format) {
		if ((battery.timeToGo || 0) <= 0) {
			return ""
		}
		const text = Utils.secondsToString(battery.timeToGo)
		if (format === VenusOS.Battery_TimeToGo_LongFormat) {
			//: %1 = time remaining, e.g. '3h 2m'
			//% "%1 to go"
			return qsTrId("brief_battery_time_to_go").arg(text)
		} else {
			return text
		}
	}

	function batteryIcon(battery) {
		return isNaN(battery.power) || battery.power === 0 ? "/images/battery.svg"
			: (battery.power > 0 ? "/images/battery_charging.svg" : "/images/battery_discharging.svg")
	}

	function batteryMode(battery) {
		return isNaN(battery.power) || battery.power === 0 ? VenusOS.Battery_Mode_Idle
			: (battery.power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)
	}

	function modeToText(mode) {
		switch (mode) {
		case VenusOS.Battery_Mode_Idle:
			return CommonWords.idle
		case VenusOS.Battery_Mode_Charging:
			return CommonWords.charging
		case VenusOS.Battery_Mode_Discharging:
			return CommonWords.discharging
		default:
			return ""
		}
	}

	Component.onCompleted: Global.batteries = root
}
