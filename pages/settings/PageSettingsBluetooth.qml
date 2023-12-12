/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {

		model: ObjectModel {

			ListSwitch {
				id: bluetoothEnabled

				text: CommonWords.enabled
				dataSource: "com.victronenergy.settings/Settings/Services/Bluetooth"
			}

			ListTextField {
				//% "Pincode"
				text: qsTrId("settings_pincode")
				visible: bluetoothEnabled.checked
				dataSource: "com.victronenergy.settings/Settings/Ble/Service/Pincode"
				writeAccessLevel: Enums.User_AccessType_User
				textField.maximumLength: 6
				textField.inputMethodHints: Qt.ImhDigitsOnly
				onAccepted: {
					Global.showToastNotification(Enums.Notification_Info,
						   //% "It might be necessary to remove existing pairing information before connecting."
						   qsTrId("settings_bluetooth_remove_existing_pairing_info"),
						   10000)
				}
			}
		}
	}
}
