/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: relay

	property string serviceUid
	property int relayIndex

	readonly property string name: Global.relays.relayName(relayIndex)
	readonly property int relayFunction: _relayFunction.value === undefined ? -1 : _relayFunction.value
	readonly property int state: _veState.value === undefined ? -1 : _veState.value

	function setState(newState) {
		_veState.setValue(newState)
	}

	readonly property bool _valid: state >= 0
	on_ValidChanged: {
		const index = Utils.findIndex(Global.relays.model, relay)
		if (_valid && index < 0) {
			Global.relays.addRelay(relay)
		} else if (!_valid && index >= 0) {
			Global.relays.removeRelay(index)
		}
	}

	onRelayFunctionChanged: {
		Global.relays.relayFunctionChanged(relay)
	}

	readonly property VeQuickItem _veState: VeQuickItem {
		uid: relay.serviceUid + "/State"
	}

	readonly property DataPoint _relayFunction: DataPoint {
		source: relay.relayIndex === 0
			 ? "com.victronenergy.settings/Settings/Relay/Function"
			 : "com.victronenergy.settings/Settings/Relay/%1/Function".arg(model.index)
	}
}
