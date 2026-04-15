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
	property string text

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
	implicitHeight: contentLayout.y + contentLayout.height

	// Block mouse events beneath the toast notification area.
	MouseArea {
		anchors.fill: parent
	}

	Rectangle {
		id: background

		anchors.fill: parent
		radius: Theme.geometry_toastNotification_radius
		color: root.type === VenusOS.Notification_Alarm ? Theme.color_toastNotification_background_error
			: root.type === VenusOS.Notification_Warning ? Theme.color_toastNotification_background_warning
			: Theme.color_toastNotification_background_informative

		Rectangle {
			id: highlight
			anchors {
				left: parent.left
				top: parent.top
				bottom: parent.bottom
			}

			visible: root.type !== ToastNotification.None
			width: Theme.geometry_toastNotification_highlightWidth
			topLeftRadius: parent.radius
			bottomLeftRadius: parent.radius

			color: root.type === VenusOS.Notification_Alarm ? Theme.color_toastNotification_highlight_error
				: root.type === VenusOS.Notification_Warning ? Theme.color_toastNotification_highlight_warning
				: Theme.color_toastNotification_highlight_informative

			CP.IconImage {
				id: notificationIcon

				x: (parent.width - width) / 2
				y: Theme.screenSize === Theme.Portrait
				   ? Theme.geometry_toastNotification_verticalMargin + Theme.geometry_toastNotification_padding
				   : (parent.height - height) / 2
				color: Theme.color_toastNotification_foreground
				source: root.type === VenusOS.Notification_Alarm ? "qrc:/images/icon_alarm_32.svg"
					: root.type === VenusOS.Notification_Warning ? "qrc:/images/icon_warning_32.svg"
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
			}
			columns: Theme.screenSize === Theme.Portrait && root.isSilenceButton ? 1 : 2
			rowSpacing: 0
			columnSpacing: 0

			Label {
				id: label

				leftPadding: Theme.geometry_toastNotification_padding
				verticalAlignment: Text.AlignVCenter
				text: root.text
				wrapMode: Text.Wrap
				maximumLineCount: 12
				elide: Text.ElideRight
				color: Theme.color_toastNotification_foreground

				Layout.fillWidth: true
				Layout.topMargin: Theme.geometry_toastNotification_padding
				Layout.bottomMargin: Theme.screenSize === Theme.Portrait && silenceButton.visible ? 0
						: Theme.geometry_toastNotification_padding
			}

			Button {
				leftInset: Theme.geometry_toastNotification_padding
				rightInset: Theme.geometry_toastNotification_padding
				topInset: Theme.geometry_toastNotification_padding
				bottomInset: Theme.geometry_toastNotification_padding
				defaultBackgroundWidth: Theme.geometry_button_touch_size
				defaultBackgroundHeight: Theme.geometry_button_touch_size
				color: Theme.color_toastNotification_foreground
				icon.source: "qrc:/images/icon_close_32.svg"
				visible: !root.isSilenceButton

				Layout.alignment: Qt.AlignTop
				onClicked: root._buttonClicked()
			}

			SilenceAlarmButton {
				id: silenceButton

				color: Theme.color_toastNotification_foreground
				flat: true
				font.pixelSize: Theme.font_toastSnoozeButton_size
				visible: root.isSilenceButton
				leftInset: Theme.geometry_toastNotification_padding
				rightInset: Theme.geometry_toastNotification_padding
				topInset: Theme.geometry_toastNotification_padding
				bottomInset: Theme.geometry_toastNotification_padding

				Layout.fillWidth: Theme.screenSize === Theme.Portrait
				onClicked: root._buttonClicked()

				Rectangle {
					anchors {
						fill: parent
						margins: Theme.geometry_toastNotification_padding
					}
					radius: parent.radius
					color: "transparent"
					border.color: Theme.color_toastNotification_foreground
					border.width: Theme.geometry_button_border_width
				}
			}
		}
	}
}
