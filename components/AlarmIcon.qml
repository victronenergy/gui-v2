/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CP.ColorImage {
	required property int alarmStatus

	source: alarmStatus === VenusOS.Alarm_Level_OK ? "qrc:/images/icon_checkmark_32.svg"
		: alarmStatus === VenusOS.Alarm_Level_Warning ? "qrc:/images/icon_warning_32.svg" : "qrc:/images/icon_alarm_32.svg"
	color: alarmStatus === VenusOS.Alarm_Level_OK ? Theme.color_green
		: alarmStatus === VenusOS.Alarm_Level_Warning ? Theme.color_orange : Theme.color_red
	visible: alarmStatus !== -1
}
