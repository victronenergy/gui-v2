/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// These product names should NOT be translated.
	function _findProductName(tokenPart) {
		switch (tokenPart) {
		case "evcharger":
			return "EV Charging Station"
		case "homeassistant":
			return "Home Assistant"
		case "opencampercore":
			return "OpenCamperCore"
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
			if (!valid) {
				mqttDevicesView.model = []
				return
			}
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

			ListPairingModeButton {
				countDownUid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/CountDown"
				preferredVisible: pairingEnable.valid
				onClicked: pairingEnable.setValue("")

				VeQuickItem {
					id: pairingEnable
					uid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/Enable"
				}
			}

			PrimaryListLabel {
				//% "Activate Pairing mode to allow a device to connect. Paired devices appear here, and will show in the Devices list when connected."
				text: qsTrId("mqtt_devices_pairing_description")
				visible: mqttDevicesView.count === 0
				font.pixelSize: Theme.font_size_caption
			}

			SectionHeader {
				//% "Paired devices"
				text: qsTrId("pairing_mqtt_paired_devices")
				visible: mqttDevicesView.count > 0
			}
		}

		delegate: ListUnpairButton {
			required property var modelData
			readonly property string tokenName: modelData["token_name"] ?? ""
			readonly property var tokenNameParts: tokenName.split("/")

			text: "%1 (%2)".arg(root._findProductName(tokenNameParts[1])).arg(tokenNameParts[2] ?? "")
			onClicked: {
				Global.dialogLayer.open(unpairDialogComponent, { tokenName: tokenName })
			}
		}
	}

	Component {
		id: unpairDialogComponent

		UnpairDialog {
			required property string tokenName

			name: tokenName.split("/").pop() ?? ""
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
