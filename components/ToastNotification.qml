/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int category: VenusOS.Notification_Info
	property alias backgroundColor: background.color
	property alias highlightColor: highlight.color
	property alias icon: icon
	property alias text: label.text
	property alias autoCloseInterval: timer.interval

	signal dismissed()

	implicitWidth: parent ? parent.width : 0
	implicitHeight: Math.max(Theme.geometry_toastNotification_minHeight,
			label.implicitHeight + 2*Theme.geometry_toastNotification_label_padding)

	Behavior on opacity { OpacityAnimator { duration: Theme.animation_toastNotification_fade_duration } }
	opacity: dismiss.dismissClicked ? 0.0
		: dismiss.dismissAvailable  ? 1.0
		: 0.0
	onOpacityChanged: if (dismiss.dismissClicked && opacity === 0.0) root.dismissed()
	Component.onCompleted: dismiss.dismissAvailable = true // ensures fade-in as well as fade-out transition.

	Rectangle {
		id: background
		anchors.fill: parent

		radius: Theme.geometry_toastNotification_radius
		color: root.category === VenusOS.Notification_Confirm ? Theme.color_toastNotification_background_confirmation
			 : root.category === VenusOS.Notification_Warning ? Theme.color_toastNotification_background_warning
			 : root.category === VenusOS.Notification_Alarm ? Theme.color_toastNotification_background_error
			 : Theme.color_toastNotification_background_informative

		AsymmetricRoundedRectangle {
			id: highlight
			anchors {
				left: parent.left
				top: parent.top
				bottom: parent.bottom
			}

			visible: root.category !== ToastNotification.None
			width: Theme.geometry_toastNotification_minHeight
			radius: parent.radius
			flat: true

			color: root.category === VenusOS.Notification_Confirm ? Theme.color_toastNotification_highlight_confirmation
				 : root.category === VenusOS.Notification_Warning ? Theme.color_toastNotification_highlight_warning
				 : root.category === VenusOS.Notification_Alarm ? Theme.color_toastNotification_highlight_error
				 : Theme.color_toastNotification_highlight_informative

			CP.IconImage {
				id: icon
				anchors.centerIn: parent

				width: Theme.geometry_toastNotification_icon_width
				color: Theme.color_toastNotification_foreground
				source: root.category === VenusOS.Notification_Confirm ? "qrc:/images/toast_icon_checkmark.svg"
					  : root.category === VenusOS.Notification_Warning ? "qrc:/images/toast_icon_alarm.svg"
					  : root.category === VenusOS.Notification_Alarm ? "qrc:/images/toast_icon_alarm.svg"
					  : "qrc:/images/toast_icon_info.svg"
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

			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			wrapMode: Text.Wrap
			color: Theme.color_toastNotification_foreground
		}

		MouseArea {
			id: dismiss
			anchors {
				right: parent.right
				top: parent.top
				bottom: parent.bottom
			}

			property bool dismissClicked: false
			property bool dismissAvailable: false
			width: Theme.geometry_toastNotification_minHeight
			onClicked: dismissClicked = true

			CP.IconImage {
				id: dismissIcon
				anchors.centerIn: parent

				width: Theme.geometry_toastNotification_icon_width
				color: Theme.color_toastNotification_foreground
				source: "qrc:/images/toast_icon_close.svg"
			}
		}
	}

	Timer {
		id: timer

		onTriggered: root.dismissed()
		onIntervalChanged: {
			if (interval !== 0) {
				start()
			}
		}
	}
}
