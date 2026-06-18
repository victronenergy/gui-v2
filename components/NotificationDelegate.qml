/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	required property int modelId

	required property bool active
	required property bool acknowledged
	required property int type
	required property date dateTime
	required property string description
	required property string deviceName
	required property string value

	readonly property bool historical: root.acknowledged && !root.active
	readonly property notificationData entry: NotificationModel.get(modelId)

	background: ListItemBackground {
		border.width: root.acknowledged ? 0 : Theme.geometry_notificationsPage_delegate_unacknowledged_border_width
		border.color: Theme.color_notificationsPage_delegate_unacknowledged_border
		color: root.acknowledged ? Theme.color_listItem_background : Theme.color_notificationsPage_delegate_unacknowledged_background
	}

	contentItem: Item {
		implicitWidth: Theme.geometry_listItem_width
		implicitHeight: Math.max(icon.implicitHeight,
			timestampLabel.implicitHeight,
			(descriptionLabel.visible && secondaryLabel.visible)
				? descriptionLabel.implicitHeight + secondaryLabel.anchors.topMargin + secondaryLabel.implicitHeight
			: descriptionLabel.visible ? descriptionLabel.implicitHeight
			: secondaryLabel.visible ? secondaryLabel.implicitHeight
			: 0)

		CP.ColorImage {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			color: root.type === VenusOS.Notification_Info
				? (root.historical ? Theme.color_darkOk : Theme.color_ok)
				: root.type === VenusOS.Notification_Warning
					? (root.historical ? Theme.color_darkWarning : Theme.color_warning)
					: (root.historical ? Theme.color_darkCritical : Theme.color_critical)
			source: root.type === VenusOS.Notification_Info
				? "qrc:/images/icon_info_32.svg"
				: root.type === VenusOS.Notification_Warning
					? "qrc:/images/icon_warning_32.svg"
					: "qrc:/images/icon_alarm_32.svg"
		}

		Label {
			id: timestampLabel
			anchors {
				top: parent.top
				right: parent.right
			}
			color: secondaryLabel.color
			font.pixelSize: Theme.font_notification_timestamp_size
			text: Utils.formatTimestamp(root.dateTime, ClockTime.dateTime)
		}


		Label {
			id: descriptionLabel
			anchors {
				top: parent.top
				left: icon.right
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				right: timestampLabel.left
				rightMargin: Theme.geometry_listItem_content_horizontalMargin
			}

			wrapMode: Text.Wrap
			visible: root.description.length > 0 || root.value.length > 0
			elide: Text.ElideRight
			color: root.historical ? Theme.color_listItem_secondaryText : Theme.color_font_primary
			font: root.font
			//: %1 = notification description (e.g. 'High temperature'), %2 = the value that triggered the notification (e.g. '25 C')
			//% "%1 %2"
			text: qsTrId("notification_description_and_value").arg(root.description).arg(root.value)
		}

		Label {
			id: secondaryLabel
			anchors {
				top: descriptionLabel.visible ? descriptionLabel.bottom : parent.top
				topMargin: descriptionLabel.visible ? Theme.geometry_listItem_content_verticalSpacing : 0
				left: icon.right
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				right: descriptionLabel.visible ? parent.right : timestampLabel.left
				rightMargin: descriptionLabel.visible ? 0 : Theme.geometry_listItem_content_horizontalMargin
			}

			wrapMode: Text.Wrap
			visible: text.length > 0
			color: root.historical ? Theme.color_font_disabled : Theme.color_listItem_secondaryText
			font.pixelSize: descriptionLabel.visible ? Theme.font_listItem_secondary_size : Theme.font_listItem_primary_size
			text: root.deviceName
		}
	}
}
