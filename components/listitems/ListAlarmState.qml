/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	//% "Alarm state"
	text: qsTrId("list_alarm_state")
	preferredVisible: dataItem.valid
	secondaryText: {
		if (dataItem.value === 0) {
			return CommonWords.ok
		} else if (dataItem.value === 1) {
			//: Alarm state is active
			//% "Alarm"
			return qsTrId("devicelist_battery_alarm_state")
		} else {
			return ""
		}
	}
}
