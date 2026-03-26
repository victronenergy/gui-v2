/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItemControl {
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
		implicitHeight: textLayout.height

		CP.ColorImage {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			color: root.type === VenusOS.Notification_Info
				? (root.historical ? Theme.color_darkOk : Theme.color_ok)
				: root.type === VenusOS.Notification_Warning
					? (root.historical ? Theme.color_darkWarning : Theme.color_warning)
					: (root.historical ? Theme.color_darkCritical : Theme.color_critical)
			source: root.type === VenusOS.Notification_Info
					? "qrc:/images/icon_info_32.svg" : "qrc:/images/icon_warning_32.svg"
		}

		GridLayout {
			id: textLayout

			anchors {
				left: icon.right
				leftMargin: Theme.geometry_listItem_content_horizontalMargin
				right: parent.right
				verticalCenter: parent.verticalCenter
			}
			columnSpacing: Theme.geometry_gradientList_spacing
			rowSpacing: Theme.geometry_listItem_content_verticalSpacing
			columns: 2

			Label {
				id: descriptionLabel

				wrapMode: Text.Wrap
				visible: root.description.length > 0 || root.value.length > 0
				elide: Text.ElideRight
				color: root.historical ? Theme.color_listItem_secondaryText : Theme.color_font_primary
				font: root.font
				//: %1 = notification description (e.g. 'High temperature'), %2 = the value that triggered the notification (e.g. '25 C')
				//% "%1 %2"
				text: qsTrId("notification_description_and_value").arg(root.description).arg(root.value)

				Layout.fillWidth: true
			}

			Label {
				color: secondaryLabel.color
				font.pixelSize: Theme.font_notification_timestamp_size
				text: Utils.formatTimestamp(root.dateTime, ClockTime.dateTime)

				Layout.alignment: Qt.AlignTop
			}

			Label {
				id: secondaryLabel

				wrapMode: Text.Wrap
				visible: text.length > 0
				color: root.historical ? Theme.color_font_disabled : Theme.color_listItem_secondaryText
				font.pixelSize: descriptionLabel.visible ? Theme.font_size_body1 : Theme.font_size_body2
				text: root.deviceName

				Layout.fillWidth: true
				Layout.columnSpan: 2
			}
		}
	}
}
