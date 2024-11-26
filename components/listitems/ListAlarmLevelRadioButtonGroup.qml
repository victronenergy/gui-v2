/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	optionModel: [
		{ display: CommonWords.disabled, value: 0 },
		//% "Alarm only"
		{ display: qsTrId("alarm_level_alarm_only"), value: 1 }, // no pre-alarms
		//% "Alarms & warnings"
		{ display: qsTrId("alarm_level_alarms_and_warnings"), value: 2 }
	]
}
