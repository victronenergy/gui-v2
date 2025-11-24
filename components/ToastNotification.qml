/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int notificationModelId
	property int toastModelId

	property int type: VenusOS.Notification_Info
	property alias backgroundColor: background.color
	property alias highlightColor: highlight.color
	property alias icon: icon
	property alias text: label.text

	function close(immediately) {
		if (immediately) {
			closed()
		} else {
			dismissed()
		}
	}

	signal dismissed()
	signal closed()

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Math.max(Theme.geometry_toastNotification_minHeight,
			label.implicitHeight + 2*Theme.geometry_toastNotification_label_padding)

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

		Label {
			id: label
			anchors {
				left: highlight.right
				right: dismiss.left
				top: parent.top
				bottom: parent.bottom
				margins: Theme.geometry_toastNotification_label_padding
			}

			horizontalAlignment: Text.AlignLeft
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.Wrap
			maximumLineCount: 12
			elide: Text.ElideRight
			color: Theme.color_toastNotification_foreground
		}

		PressArea {
			id: dismiss
			anchors {
				right: parent.right
				top: parent.top
				bottom: parent.bottom
				margins: isSilenceButton ? Theme.geometry_toastNotification_label_padding : 0
			}

			readonly property bool isSilenceButton: notificationModelId !== 0 && (root.type === VenusOS.Notification_Warning || root.type === VenusOS.Notification_Alarm)
			width: isSilenceButton ? silenceLabel.x + silenceLabel.implicitWidth + silenceLabel.anchors.rightMargin
				: Theme.geometry_toastNotification_minHeight
			radius: isSilenceButton ? Theme.geometry_button_radius : Theme.geometry_button_border_width

			onClicked: {
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

			CP.IconImage {
				id: dismissIcon
				anchors {
					verticalCenter: parent.verticalCenter
					left: parent.left
					leftMargin: Theme.geometry_silenceAlarmButton_horizontalPadding
				}

				color: Theme.color_toastNotification_foreground
				source: dismiss.isSilenceButton ? "qrc:/images/icon_alarm_snooze_24.svg"
					: "qrc:/images/icon_close_32.svg"
			}

			Label {
				id: silenceLabel
				anchors {
					verticalCenter: parent.verticalCenter
					left: dismissIcon.right
					right: parent.right
					leftMargin: dismissIcon.anchors.leftMargin
					rightMargin: dismissIcon.anchors.leftMargin
				}
				visible: dismiss.isSilenceButton
				text: CommonWords.silence_alarm
				color: dismissIcon.color
				font.pixelSize: Theme.font_size_tiny
			}

			Rectangle {
				id: silenceBorder
				anchors.fill: parent
				visible: dismiss.isSilenceButton
				radius: parent.radius
				color: "transparent"
				border.color: dismissIcon.color
				border.width: Theme.geometry_button_border_width
			}
		}
	}
}
