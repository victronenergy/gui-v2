/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	required property string countDownUid

	//% "Pairing mode"
	text: qsTrId("mqtt_devices_pairing_mode")
	secondaryText: readOnly
			  //: %1 = number of seconds remaining
			  //% "Active \u2022 %1s remaining"
			? qsTrId("mqtt_devices_pairing_active").arg(pairingCountDown.secondsRemaining)
			  //% "Activate"
			: qsTrId("mqtt_devices_pairing_activate")
	readOnly: pairingCountDown.secondsRemaining > 0
	writeAccessLevel: VenusOS.User_AccessType_User

	VeQuickItem {
		id: pairingCountDown

		property bool notificationShown
		readonly property int secondsRemaining: value || 0

		uid: root.countDownUid
		onSecondsRemainingChanged: {
			if (secondsRemaining > 0) {
				if (!notificationShown) {
					Global.showToastNotification(VenusOS.Notification_Info,
							//% "Pairing mode enabled for %1 seconds"
							qsTrId("mqtt_devices_pairing_enabled").arg(secondsRemaining), 5000)
				}
				notificationShown = true
			} else {
				notificationShown = false
			}
		}
	}
}
