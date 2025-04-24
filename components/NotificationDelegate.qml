/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

BaseListItem {
	id: root

	required property BaseNotification notification
	required property int notificationId
	required property bool active
	required property bool acknowledged
	required property int type
	required property date dateTime
	required property string description
	required property string deviceName
	required property string value

	width: parent ? parent.width : 0
	height: textColumn.height

	Rectangle {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_notificationsPage_delegate_marker_topMargin
			left: parent.left
			leftMargin: Theme.geometry_notificationsPage_delegate_marker_topMargin
		}
		width: Theme.geometry_notificationsPage_delegate_marker_width
		height: Theme.geometry_notificationsPage_delegate_marker_width
		radius: Theme.geometry_notificationsPage_delegate_marker_radius
		color: Theme.color_critical
		visible: !root.acknowledged
	}

	Item {
		id: iconContainer

		width: icon.width + (2 * Theme.geometry_listItem_content_horizontalMargin)
		height: parent.height

		CP.ColorImage {
			id: icon
			anchors.centerIn: parent
			color: root.type === VenusOS.Notification_Info
				   ? (root.active ? Theme.color_ok : Theme.color_darkOk)
				   : root.type === VenusOS.Notification_Warning
					 ? (root.active ? Theme.color_warning : Theme.color_darkWarning)
					 : (root.active ? Theme.color_critical : Theme.color_darkCritical)
			source: root.type === VenusOS.Notification_Info
					? "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		}
	}

	Column {
		id: textColumn

		anchors {
			left: iconContainer.right
			right: timestamp.left
			rightMargin: Theme.geometry_listItem_content_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		spacing: Theme.geometry_gradientList_spacing
		topPadding: Theme.geometry_listItem_content_verticalMargin
		bottomPadding: Theme.geometry_listItem_content_verticalMargin

		Label {
			id: descriptionLabel

			width: parent.width
			wrapMode: Text.Wrap
			visible: root.description.length > 0 || root.value.length > 0
			elide: Text.ElideRight
			color: Theme.color_font_primary
			font.pixelSize: Theme.font_size_body2
			//: %1 = notification description (e.g. 'High temperature'), %2 = the value that triggered the notification (e.g. '25 C')
			//% "%1 %2"
			text: qsTrId("notification_description_and_value").arg(root.description).arg(root.value)
		}

		Label {
			width: parent.width
			wrapMode: Text.Wrap
			visible: text.length > 0
			color: Theme.color_listItem_secondaryText
			font.pixelSize: descriptionLabel.visible ? Theme.font_size_body1 : Theme.font_size_body2
			text: root.deviceName
		}
	}

	Label {
		id: timestamp

		anchors {
			top: parent.top
			topMargin: Theme.geometry_listItem_content_verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin
		}

		color: Theme.color_listItem_secondaryText
		font.pixelSize: Theme.font_size_body1
		text: Utils.formatTimestamp(root.dateTime, ClockTime.dateTime)
	}
}
