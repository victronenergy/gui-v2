/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import QtQml

Item {
	property string bindPrefix
	property string alarmSuffix
	property bool errorItem: false
	property var alarms: [alarm, phase1Alarm, phase2Alarm, phase3Alarm]
	property int numOfPhases: 1

	property VeQuickItem alarm: VeQuickItem {
		property string displayText: getDisplayText(value)
		uid: bindPrefix + "/Alarms" + alarmSuffix
	}

	property VeQuickItem phase1Alarm: VeQuickItem {
		property string displayText: (numOfPhases === 1 ? "" : "L1: ") + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L1" + alarmSuffix
	}

	property VeQuickItem phase2Alarm: VeQuickItem {
		property string displayText: "L2: " + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L2" + alarmSuffix
	}

	property VeQuickItem phase3Alarm: VeQuickItem {
		property string displayText: "L3: " + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L3" + alarmSuffix
	}

	function getDisplayText(value)
	{
		switch(value) {
		case 0:
			return CommonWords.ok
		case 1:
			//% "Warning"
			return qsTrId("vebus_device_alarm_group_warning")
		case 2:
			return errorItem ? CommonWords.error : CommonWords.alarm
		default:
			return "--"
		}
	}
}
