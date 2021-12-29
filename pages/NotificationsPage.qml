/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	Label {
		id: label
		anchors.top: parent.top
		anchors.topMargin: 20
		anchors.horizontalCenter: parent.horizontalCenter
		text: "NotificationsPage placeholder"
	}

	Column {
		anchors {
			top: label.bottom
			topMargin: Theme.geometry.page.grid.horizontalMargin
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Theme.geometry.page.grid.horizontalMargin

		Button {
			anchors.horizontalCenter: parent.horizontalCenter

			topPadding: 12
			bottomPadding: 12
			leftPadding: 20
			rightPadding: 20

			flat: false

			//% "Generate Modal Notification"
			//: Generate a fullscreen modal warning notification
			text: qsTrId("notifications_generate_modal_notification")

			//% "Inverter temperature"
			property string warningNotificationTitle: qsTrId("notifications_warning_title_inverter_temperature")
			//% "Suggest user an action or inaction, inform about status.  This text can be long and should wrap."
			property string warningNotificationDescription: qsTrId("notifications_warning_description_inverter_temperature")

			onClicked: {
				dialogManager.showWarning(warningNotificationTitle,  warningNotificationDescription)
			}
		}

		Button {
			anchors.horizontalCenter: parent.horizontalCenter

			topPadding: 12
			bottomPadding: 12
			leftPadding: 20
			rightPadding: 20

			flat: false

			//% "Generate Toast Notification"
			//: Generate a popup (toast) notification
			text: qsTrId("notifications_generate_toast_notification")

			//% "Mollitia quis est quas deleniti quibusdam explicabo quasi."
			property string shortText: qsTrId("notifications_toast_short_text")

			//% "Mollitia quis est quas deleniti quibusdam explicabo quasi. Voluptatem qui quia et consequuntur."
			property string longText: qsTrId("notifications_toast_long_text")

			property int currentCategory: ToastNotification.Category.Error
			property bool useShortText: false

			onClicked: {
				currentCategory = (currentCategory + 1)
				if (currentCategory > ToastNotification.Category.Error) {
					currentCategory = ToastNotification.Category.None
					useShortText = !useShortText
				}
				dialogManager.showToastNotification(currentCategory, useShortText ? shortText : longText)
			}
		}
	}
}
