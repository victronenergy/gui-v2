/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	//% "Alarm state"
	text: qsTrId("list_alarm_state")
	visible: defaultVisible && dataValid
	secondaryText: {
		if (dataValue === 0) {
			return CommonWords.ok
		} else if (dataValue === 1) {
			//: Alarm state is active
			//% "Alarm"
			return qsTrId("devicelist_battery_alarm_state")
		} else {
			return ""
		}
	}
}
