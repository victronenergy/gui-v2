/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQuickItem {
		id: hasBluetoothSupport
		uid: Global.venusPlatform.serviceUid + "/Network/HasBluetoothSupport"
	}

	GradientListView {

		model: hasBluetoothSupport.value ? bluetoothAvailable : bluetoothUnavailable

		VisibleItemModel {
			id: bluetoothUnavailable

			PrimaryListLabel {
				//% "Connect a compatible Bluetooth USB dongle to enable Bluetooth connectivity."
				text: qsTrId("settings_bluetooth_unavailable_message")
			}
		}

		VisibleItemModel {
			id: bluetoothAvailable

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
				maximumLength: 6
				inputMethodHints: Qt.ImhDigitsOnly
				saveInput: function() {
					dataItem.setValue(secondaryText)
					Global.showToastNotification(VenusOS.Notification_Info,
						   //% "It might be necessary to remove existing pairing information before connecting."
						   qsTrId("settings_bluetooth_remove_existing_pairing_info"),
						   10000)
				}
			}
		}
	}
}
