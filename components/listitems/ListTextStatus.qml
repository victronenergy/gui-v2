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
		implicitHeight: labelLayout.implicitHeight + (captionLabel.visible ? captionLabel.implicitHeight : 0)

		TwoLabelLayout {
			id: labelLayout

			anchors {
				left: parent.left
				right: parent.right
				rightMargin: alarmStatusIcon.visible ? alarmStatusIcon.width + root.spacing : 0
				verticalCenter: parent.verticalCenter
				verticalCenterOffset: captionLabel.visible ? -captionLabel.height/2 : 0
			}
			primaryText: root.text
			primaryLabel.font: root.font
			primaryLabel.textFormat: root.textFormat
			secondaryText: root.secondaryText
		}

		CP.ColorImage {
			id: alarmStatusIcon

			anchors {
				right: parent.right
				verticalCenter: labelLayout.verticalCenter
			}
			source: alarmStatus === VenusOS.Alarm_Level_OK ? "qrc:/images/icon_checkmark_32.svg"
				: alarmStatus === VenusOS.Alarm_Level_Warning ? "qrc:/images/icon_warning_32.svg" : "qrc:/images/icon_alarm_32.svg"
			color: alarmStatus === VenusOS.Alarm_Level_OK ? Theme.color_success
				: alarmStatus === VenusOS.Alarm_Level_Warning ? Theme.color_warning : Theme.color_critical
			visible: alarmStatus !== -1
		}

		CaptionLabel {
			id: captionLabel

			anchors {
				top: labelLayout.bottom
				left: parent.left
				right: parent.right
			}
			visible: text.length > 0
			topPadding: Theme.geometry_listItem_content_verticalSpacing
			text: root.caption
		}
	}

	VeQuickItem {
		id: dataItem
	}
}
