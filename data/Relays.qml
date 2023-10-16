/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		objectName: "relays"
	}
	property DeviceModel manualRelays: DeviceModel {
		objectName: "manualRelays"
	}

	function addRelay(relay) {
		model.addDevice(relay)
	}

	function removeRelay(relay) {
		model.removeDevice(relay.serviceUid)
		manualRelays.removeDevice(relay.serviceUid)
	}

	function reset() {
		model.clear()
		manualRelays.clear()
	}

	function relayName(index) {
		//: %1 = Relay number
		//% "Relay %1"
		return qsTrId("relay_name").arg(index + 1)
	}

	readonly property var _relayFunctionWatcher: Instantiator {
		model: root.model
		delegate: Connections {
			target: modelData

			function onRelayFunctionChanged() {
				const relayIndex = manualRelays.indexOf(target.serviceUid)
				if (relayIndex < 0 && target.relayFunction === VenusOS.Relay_Function_Manual) {
					manualRelays.addDevice(relay)
				} else if (relayIndex >= 0 && target.relayFunction !== VenusOS.Relay_Function_Manual) {
					manualRelays.removeDevice(target.serviceUid)
				}
			}
		}
	}

	Component.onCompleted: Global.relays = root
}
