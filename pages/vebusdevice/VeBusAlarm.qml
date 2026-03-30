/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListQuantityGroup {
	id: root

	property string bindPrefix
	property int numOfPhases: 1
	property bool multiPhase: numOfPhases > 1
	property bool errorItem: false
	property string alarmSuffix

	function getDisplayText(value) {
		switch (value) {
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

	model: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject {
			// Note: multi's connected to the CAN-bus still report these and don't
			// report per phase alarms, so hide it if per phase L1 is available.
			object: mainAlarm.valid && !phase1Alarm.valid ? mainAlarm : null
			key: "displayText"
			unit: VenusOS.Units_None
		}
		QuantityObject {
			object: phase1Alarm.valid ? phase1Alarm : null
			key: "displayText"
			unit: VenusOS.Units_None
		}
		QuantityObject {
			object: phase2Alarm.valid && root.multiPhase && numOfPhases >= 2 ? phase2Alarm : null
			key: "displayText"
			unit: VenusOS.Units_None
		}
		QuantityObject {
			object: phase3Alarm.valid && root.multiPhase && numOfPhases >= 3 ? phase3Alarm : null
			key: "displayText"
			unit: VenusOS.Units_None
		}
	}

	VeQuickItem {
		id: mainAlarm
		readonly property string displayText: getDisplayText(value)
		uid: bindPrefix + "/Alarms" + alarmSuffix
	}

	VeQuickItem {
		id: phase1Alarm
		readonly property string displayText: (numOfPhases === 1 ? "" : "L1: ") + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L1" + alarmSuffix
	}

	VeQuickItem {
		id: phase2Alarm
		readonly property string displayText: "L2: " + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L2" + alarmSuffix
	}

	VeQuickItem {
		id: phase3Alarm
		readonly property string displayText: "L3: " + getDisplayText(value)
		uid: bindPrefix + "/Alarms/L3" + alarmSuffix
	}
}
