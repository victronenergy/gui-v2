/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {

		model: VisibleItemModel {

			ListSwitch {
				id: bluetoothEnabled

				text: CommonWords.enabled
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Bluetooth"
			}

			ListTextField {
				//% "Pincode"
				text: qsTrId("settings_pincode")
				preferredVisible: bluetoothEnabled.checked
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Ble/Service/Pincode"
				writeAccessLevel: VenusOS.User_AccessType_User
				textField.maximumLength: 6
				textField.inputMethodHints: Qt.ImhDigitsOnly
				saveInput: function() {
					dataItem.setValue(textField.text)
					Global.showToastNotification(VenusOS.Notification_Info,
						   //% "It might be necessary to remove existing pairing information before connecting."
						   qsTrId("settings_bluetooth_remove_existing_pairing_info"),
						   10000)
				}
			}
		}
	}
}
