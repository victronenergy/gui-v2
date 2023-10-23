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

	function timeToGoText(battery) {
		if ((battery.timeToGo || 0) <= 0) {
			return ""
		}
		const timeToGo = Utils.decomposeDurationDaysHoursMinutes(battery.timeToGo)
		if (timeToGo.d > 0) {
			//% "%1d %2h %3m"
			return qsTrId("batteries_time_to_go_days_hours_minutes").arg(timeToGo.d).arg(timeToGo.h).arg(timeToGo.m)
		} else if (timeToGo.h > 0) {
			//% "%2h %3m"
			return qsTrId("batteries_time_to_go_hours_minutes").arg(timeToGo.h).arg(timeToGo.m)
		} else {
			//% "%3m"
			return qsTrId("batteries_time_to_go_minutes").arg(timeToGo.m)
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

	Component.onCompleted: Global.batteries = root
}
