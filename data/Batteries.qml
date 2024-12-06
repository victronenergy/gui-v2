/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function timeToGoText(timeToGo, format) {
		if ((timeToGo || 0) <= 0) {
			return ""
		}
		const text = Utils.secondsToString(timeToGo)
		if (format === VenusOS.Battery_TimeToGo_LongFormat) {
			//: %1 = time remaining, e.g. '3h 2m'
			//% "%1 to go"
			return qsTrId("brief_battery_time_to_go").arg(text)
		} else {
			return text
		}
	}

	function batteryIcon(power) {
		return isNaN(power) || power === 0 ? "qrc:/images/icon_battery_24.svg"
			: (power > 0 ? "qrc:/images/icon_battery_charging_24.svg" : "qrc:/images/icon_battery_discharging_24.svg")
	}

	function batteryMode(power) {
		return isNaN(power) || power === 0 ? VenusOS.Battery_Mode_Idle
			: (power > 0 ? VenusOS.Battery_Mode_Charging : VenusOS.Battery_Mode_Discharging)
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
