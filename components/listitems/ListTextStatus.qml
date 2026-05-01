/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

/*
	A list setting item with additional secondary text and alarm-type icon.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property string secondaryText: dataItem.valid ? dataItem.value : ""
	property int alarmStatus: -1

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: labelLayout.height

		ThreeLabelLayout {
			id: labelLayout

			anchors {
				left: parent.left
				right: alarmStatusIcon.visible ? alarmStatusIcon.left : parent.right
				rightMargin: alarmStatusIcon.visible ? root.spacing : 0
				verticalCenter: parent.verticalCenter
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
			captionText: root.caption
		}

		CP.ColorImage {
			id: alarmStatusIcon

			anchors {
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			source: alarmStatus === VenusOS.Alarm_Level_OK ? "qrc:/images/icon_checkmark_32.svg"
				: alarmStatus === VenusOS.Alarm_Level_Warning ? "qrc:/images/icon_warning_32.svg" : "qrc:/images/icon_alarm_32.svg"
			color: alarmStatus === VenusOS.Alarm_Level_OK ? Theme.color_green
				: alarmStatus === VenusOS.Alarm_Level_Warning ? Theme.color_orange : Theme.color_red
			visible: alarmStatus !== -1
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
