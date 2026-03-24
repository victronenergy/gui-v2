/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var userTokens: []

	function setPlatformValue(path, value) {
		MockManager.setValue(Global.venusPlatform.serviceUid + path, value)
	}

	function platformValue(path) {
		return MockManager.value(Global.venusPlatform.serviceUid + path)
	}

	function removeToken(tokenName) {
		let temp = root.userTokens.slice()
		for (let i = 0; i < temp.length; ++i) {
			if (temp[i].token_name === tokenName) {
				temp.splice(i, 1)
				break
			}
		}
		root.userTokens = temp
	}

	onUserTokensChanged: {
		setPlatformValue("/Tokens/Users", JSON.stringify(userTokens))
	}

	// Set /Tokens/Users according to the available evcharger services.
	Instantiator {
		id: evcsSerialObjects

		model: FilteredServiceModel {
			serviceTypes: ["evcharger"]
		}
		delegate: Item {
			readonly property string serial: serialItem.value ?? ""

			VeQuickItem {
				id: serialItem
				uid: model.uid + "/Serial"
			}
		}
		onObjectAdded: (index, object) => {
			let temp = root.userTokens.slice()
			temp.push({ token_name: "token/evcharger/%1".arg(object.serial) })
			root.userTokens = temp
		}
		onObjectRemoved: (index, object) => {
			root.removeToken("token/evcharger/%1".arg(object.serial))
		}
	}

	VeQuickItem {
		id: pairingEnable
		uid: Global.venusPlatform.serviceUid + "/Tokens/Pairing/Enable"
		onValueChanged: {
			if (value === "") {
				tokenPairingCountDown.running = true
			}
		}
		// On a real backend, the default value is "", but if we use that then VeQuickItem does not
		// signal when the UI writes an empty string to the value, so use a dummy string instead.
		Component.onCompleted: {
			setValue("dummy")
		}
	}

	VeQuickItem {
		id: pairingRemove
		uid: Global.venusPlatform.serviceUid + "/Tokens/Remove"
		onValueChanged: root.removeToken(value)
	}

	Timer {
		id: tokenPairingCountDown
		interval: 1000
		repeat: true
		onTriggered: {
			const countDown = platformValue("/Tokens/Pairing/CountDown")
			if (countDown) {
				setPlatformValue("/Tokens/Pairing/CountDown", countDown - 1)
				if (countDown === 1) {
					pairingEnable.setValue("dummy")
					running = false
				}
			} else {
				setPlatformValue("/Tokens/Pairing/CountDown", 10)
			}
		}
	}
}
