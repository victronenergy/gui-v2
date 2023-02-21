/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ListModel model: ListModel {}
	property ListModel manualRelays: ListModel {}

	function addRelay(relay) {
		model.append({ relay: relay })
	}

	function insertRelay(index, relay) {
		model.insert(index >= 0 && index < model.count ? index : model.count, { relay: relay })
	}

	function removeRelay(index) {
		model.remove(index)

		let manualRelayIndex = _manualRelayIndex(relay)
		if (manualRelayIndex >= 0) {
			manualRelays.remove(manualRelayIndex)
		}
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

	function relayFunctionChanged(relay) {
		let relayIndex = _manualRelayIndex(relay)
		if (relayIndex < 0 && relay.relayFunction === VenusOS.Relay_Function_Manual) {
			manualRelays.append({ relay: relay })
		} else if (relayIndex >= 0 && relay.relayFunction !== VenusOS.Relay_Function_Manual) {
			manualRelays.remove(relayIndex)
		}
	}

	function _manualRelayIndex(relay) {
		for (let i = 0; i < manualRelays.count; ++i) {
			if (manualRelays.get(i).relay === relay) {
				return i
			}
		}
		return -1
	}

	Component.onCompleted: Global.relays = root
}
