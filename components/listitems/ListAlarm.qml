/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	id: root

	secondaryText: {
		switch (dataItem.value) {
		case VenusOS.Alarm_Level_OK:
			//: Voltage alarm is at "OK" level
			//% "OK"
			return qsTrId("listitems_alarm_level_ok")
		case VenusOS.Alarm_Level_Warning:
			//: Voltage alarm is at "Warning" level
			//% "Warning"
			return qsTrId("listitems_alarm_level_warning")
		case VenusOS.Alarm_Level_Alarm:
			//: Voltage alarm is at "Alarm" level
			//% "Alarm"
			return qsTrId("listitems_alarm_level_alarm")
		default:
			return ""
		}
	}
}
