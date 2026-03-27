/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	function _findProductName(tokenPart) {
		switch (tokenPart) {
		case "evcharger":
			//% "EV Charging Station"
			return qsTrId("mqtt_devices_ev_charging_station")
		default:
			return tokenPart
		}
	}

	// Value is a JSON string. For example:
	// '[{"token_name":"token/evcharger/HQ2334EV4Q"},{"token_name":"token/evcharger/HQ2334EV4R"}]'
	VeQuickItem {
		id: tokenUsers
		uid: Global.venusPlatform.serviceUid + "/Tokens/Users"
		onValueChanged: {
			let model = []
			try {
				model = JSON.parse(value)
			} catch (e) {
				console.warn(uid, ": unable to parse JSON:", value, "exception:", e)
				model = []
			}
			mqttDevicesView.model = model
		}
	}

	GradientListView {
		id: mqttDevicesView

		header: SettingsColumn {
			width: parent?.width ?? 0
			bottomPadding: spacing

			ListButton {
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

				onClicked: pairingEnable.setValue("")

				VeQuickItem {
					id: pairingEnable
					uid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/Enable"
				}

				VeQuickItem {
					id: pairingCountDown

					property bool notificationShown
					readonly property int secondsRemaining: value || 0

					uid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/CountDown"
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

			PrimaryListLabel {
				//% "Activate Pairing mode to allow a device to connect. Paired devices appear here, and will show in the Devices list when connected."
				text: qsTrId("mqtt_devices_pairing_description")
				visible: mqttDevicesView.count === 0
				font.pixelSize: Theme.font_size_caption
			}

			SectionHeader {
				//% "Access tokens for paired devices"
				text: qsTrId("mqtt_devices_pairing_access_tokens")
				visible: mqttDevicesView.count > 0
			}
		}

		delegate: ListButton {
			required property var modelData
			readonly property string tokenName: modelData["token_name"] ?? ""
			readonly property var tokenNameParts: tokenName.split("/")

			text: "%1 (%2)".arg(root._findProductName(tokenNameParts[1])).arg(tokenNameParts[2] ?? "")
			//% "Unpair"
			secondaryText: qsTrId("mqtt_devices_pairing_unpair")
			writeAccessLevel: VenusOS.User_AccessType_User
			onClicked: {
				Global.dialogLayer.open(unpairDialogComponent, { tokenName: tokenName })
			}
		}
	}

	Component {
		id: unpairDialogComponent

		ModalWarningDialog {
			required property string tokenName

			//% "Unpairing %1"
			title: qsTrId("mqtt_devices_unpairing_confirm_title").arg(tokenName.split("/")[2] ?? "")

			//% "This will disconnect the device and it will need to be paired again to reconnect."
			description: qsTrId("mqtt_devices_unpairing_confirm_description")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			onAccepted: {
				pairingRemove.setValue(tokenName)
			}

			VeQuickItem {
				id: pairingRemove
				uid: Global.venusPlatform.serviceUid + "/Tokens/Remove"
			}
		}
	}
}
