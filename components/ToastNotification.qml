/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int notificationModelId
	property int toastModelId

	property int type: VenusOS.Notification_Info
	property alias backgroundColor: background.color
	property alias highlightColor: highlight.color
	property alias text: label.text

	readonly property bool isSilenceButton: notificationModelId !== 0
			&& (root.type === VenusOS.Notification_Warning || root.type === VenusOS.Notification_Alarm)

	function close(immediately) {
		if (immediately) {
			closed()
		} else {
			dismissed()
		}
	}

	function _buttonClicked() {
		if (isSilenceButton) {
			// Silence all similar or lower-level notifications by acknowledging them.
			// Do NOT acknowledge Info notifications, as they don't buzz, and we
			// still want the user to see the number of outstanding notifications
			// in the Notifications navbar icon bubble number.
			if (root.type === VenusOS.Notification_Alarm) {
				NotificationModel.acknowledgeType(VenusOS.Notification_Alarm)
				NotificationModel.acknowledgeType(VenusOS.Notification_Warning)
			} else {
				NotificationModel.acknowledgeType(VenusOS.Notification_Warning)
			}
		}

		if (root.type === VenusOS.Notification_Info) {
			// for Info toasts, remove from the toast model (but do NOT acknowledge) all Info toasts.
			// This ensures that if something generates a hundred Info toasts in a row the user
			// doesn't have to manually dismiss them all, but can still see the number of
			// unacknowledged notifications in the Notifications navbar icon bubble number.
			ToastModel.removeAllInfoExcept(root.toastModelId)
		}

		root.dismissed()
	}

	signal dismissed()
	signal closed()

	implicitWidth: parent ? parent.width : 0
	implicitHeight: contentLayout.y + contentLayout.height + Theme.geometry_toastNotification_label_padding

	Rectangle {
		id: background

		anchors.fill: parent
		radius: Theme.geometry_toastNotification_radius
		color: root.type === VenusOS.Notification_Warning ? Theme.color_toastNotification_background_warning
			 : root.type === VenusOS.Notification_Alarm ? Theme.color_toastNotification_background_error
			 : Theme.color_toastNotification_background_informative

		Rectangle {
			id: highlight
			anchors {
				left: parent.left
				top: parent.top
				bottom: parent.bottom
			}

			visible: root.type !== ToastNotification.None
			width: Theme.geometry_toastNotification_minHeight
			topLeftRadius: parent.radius
			bottomLeftRadius: parent.radius

			color: root.type === VenusOS.Notification_Warning ? Theme.color_toastNotification_highlight_warning
				 : root.type === VenusOS.Notification_Alarm ? Theme.color_toastNotification_highlight_error
				 : Theme.color_toastNotification_highlight_informative

			CP.IconImage {
				id: icon
				anchors.centerIn: parent

				color: Theme.color_toastNotification_foreground
				source: root.type === VenusOS.Notification_Warning ? "qrc:/images/icon_warning_32.svg"
					  : root.type === VenusOS.Notification_Alarm ? "qrc:/images/icon_warning_32.svg"
					  : "qrc:/images/icon_info_32.svg"
			}
		}

		// Landscape layout:
		// |  Text   | "X" if non-alarm, "Silence alarm" if alarm
		//
		// Portrait layout
		// |  Text   | "X" if non-alarm |
		// | "Silence alarm" for alarm  |
		GridLayout {
			id: contentLayout

			anchors {
				left: highlight.right
				right: parent.right
				top: parent.top
				margins: Theme.geometry_toastNotification_label_padding
			}
			columns: Theme.screenSize === Theme.Portrait && root.isSilenceButton ? 1 : 2

			Label {
				id: label

				horizontalAlignment: Text.AlignLeft
				verticalAlignment: Text.AlignVCenter
				wrapMode: Text.Wrap
				maximumLineCount: 12
				elide: Text.ElideRight
				color: Theme.color_toastNotification_foreground

				Layout.fillWidth: true
			}

			CloseButton {
				icon.color: Theme.color_toastNotification_foreground
				visible: !root.isSilenceButton
				onClicked: root._buttonClicked()
			}

			SilenceAlarmButton {
				color: Theme.color_toastNotification_foreground
				flat: true
				visible: root.isSilenceButton
				onClicked: root._buttonClicked()

				Rectangle {
					anchors.fill: parent
					radius: parent.radius
					color: "transparent"
					border.color: Theme.color_toastNotification_foreground
					border.width: Theme.geometry_button_border_width
				}
			}
		}
	}
}
