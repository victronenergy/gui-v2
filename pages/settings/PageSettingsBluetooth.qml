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

		DelegateComponentModel {
			DelegateComponent {
				id: bluetoothUnavailable

				PrimaryListLabel {
					//% "Connect a compatible Bluetooth USB dongle to enable Bluetooth connectivity."
					text: qsTrId("settings_bluetooth_unavailable_message")
				}
			}
		}

		DelegateComponentModel {
			DelegateComponent {
				id: bluetoothAvailable
				dataItem: VeQuickItem { uid: Global.systemSettings.serviceUid + "/Settings/Services/Bluetooth" }
				property bool checked: dataItem.value === 1

				ListSwitch {
					id: bluetoothEnabled

					text: CommonWords.enabled
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Services/Bluetooth"
				}
			}

			DelegateComponent {
				preferredVisible: bluetoothAvailable.checked
				ListTextField {
					//% "Pincode"
					text: qsTrId("settings_pincode")
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
}
