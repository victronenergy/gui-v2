/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	property bool acknowledged
	property bool alarmActive
	property int category
	property date date
	property string source
	property string description

	function _formatTimestamp(date) {
		let ms = Math.floor(ClockTime.currentDateTime - date)
		let minutes = Math.floor(ms / 60000)
		if (minutes < 1) {
			//% "now"
			return qsTrId("notifications_page_now")
		}
		if (minutes < 60) {
			//% "%1m ago"
			return qsTrId("%1m ago").arg(minutes) // eg. "26m ago"
		}
		let hours = Math.floor(minutes / 60)
		let days = Math.floor(hours / 24)
		if (days < 1) {
			//% "%1h %2m ago"
			return qsTrId("%1h %2m ago").arg(hours).arg(minutes % 60) // eg. "2h 10m ago"
		}
		if (days < 7) {
			return date.toLocaleString(Qt.locale(), "ddd hh:mm") // eg. "Mon 09:06"
		}
		return date.toLocaleString(Qt.locale(), "MMM dd hh:mm") // eg. "Mar 27 10:20"
	}

	width: Theme.geometry_notificationsPage_delegate_width
	height: Theme.geometry_notificationsPage_delegate_height
	radius: Theme.geometry_toastNotification_radius
	color: mouseArea.containsPress ? Theme.color_listItem_down_background : Theme.color_background_secondary

	Row {
		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			leftMargin: Theme.geometry_notificationsPage_delegate_marker_leftMargin
		}
		Rectangle {
			anchors {
				top: parent.top
				topMargin: Theme.geometry_notificationsPage_delegate_marker_topMargin
			}
			width: Theme.geometry_notificationsPage_delegate_marker_width
			height: width
			radius: Theme.geometry_notificationsPage_delegate_marker_radius
			color: root.acknowledged ? "transparent" : Theme.color_critical
		}
		Item {
			height: 1
			width: Theme.geometry_notificationsPage_delegate_icon_spacing
		}
		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			fillMode: Image.PreserveAspectFit
			color: root.category === VenusOS.Notification_Info
				   ? (root.alarmActive ? Theme.color_ok : Theme.color_darkOk)
				   : root.category === VenusOS.Notification_Warning
					 ? (root.alarmActive ? Theme.color_warning : Theme.color_darkWarning)
					 : (root.alarmActive ? Theme.color_critical : Theme.color_darkCritical)
			source: root.category === VenusOS.Notification_Info
					? "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		}
		Item {
			height: 1
			width: Theme.geometry_notificationsPage_delegate_description_spacing_horizontal
		}
		Column {
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.geometry_notificationsPage_delegate_description_spacing_vertical

			Label {
				color: Theme.color_listItem_secondaryText
				text: root.source
			}
			Label {
				color: Theme.color_font_primary
				font.pixelSize: Theme.font_size_body2
				text: qsTrId(root.description)
			}
		}
	}
	Label {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_notificationsPage_delegate_topMargin
			right: parent.right
			rightMargin: Theme.geometry_notificationsPage_delegate_rightMargin
		}
		color: Theme.color_notificationsPage_text_color
		text: _formatTimestamp(root.date)
	}
	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: model.acknowledged = true
	}
}
