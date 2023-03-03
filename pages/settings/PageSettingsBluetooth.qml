/*
** Copyright (C) 2023 Victron Energy B.V.
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
				source: "com.victronenergy.settings/Settings/Services/Bluetooth"
			}

			ListTextField {
				//% "Pincode"
				text: qsTrId("settings_pincode")
				visible: bluetoothEnabled.checked
				source: "com.victronenergy.settings/Settings/Ble/Service/Pincode"
				writeAccessLevel: VenusOS.User_AccessType_User
				textField.maximumLength: 6
				textField.inputMethodHints: Qt.ImhDigitsOnly
				onAccepted: {
					Global.showToastNotification(VenusOS.Notification_Info,
						   //% "It might be necessary to remove existing pairing information before connecting."
						   qsTrId("settings_bluetooth_remove_existing_pairing_info"),
						   10000)
				}
			}
		}
	}
}
