/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListText {
	id: root

	readonly property alias dataItem: dataItem
	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel
	property int alarmStatus: -1

	content.children: [
		SecondaryListLabel {
			id: secondaryLabel
			anchors.verticalCenter: parent.verticalCenter
			text: dataItem.valid ? dataItem.value : ""
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: text.length > 0
		},
		CP.ColorImage {
			id: alarmStatusIcon
			anchors.verticalCenter: parent.verticalCenter
			source: alarmStatus === VenusOS.Alarm_Level_OK ? "qrc:/images/icon_checkmark_32.svg"
				: alarmStatus === VenusOS.Alarm_Level_Warning ? "qrc:/images/icon_warning_32.svg" : "qrc:/images/icon_alarm_32.svg"
			color: alarmStatus === VenusOS.Alarm_Level_OK ? Theme.color_green
				: alarmStatus === VenusOS.Alarm_Level_Warning ? Theme.color_orange : Theme.color_red
			visible: alarmStatus !== -1
		}
	]

	VeQuickItem {
		id: dataItem
	}
}
