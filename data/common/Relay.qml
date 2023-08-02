/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "/components/Utils.js" as Utils

Device {
	id: relay

	property int relayIndex
	readonly property int relayFunction: _relayFunction.value === undefined ? -1 : _relayFunction.value
	readonly property int state: _veState.value === undefined ? -1 : _veState.value

	name: !!Global.relays ? Global.relays.relayName(relayIndex) : ""

	function setState(newState) {
		_veState.setValue(newState)
	}

	readonly property VeQuickItem _veState: VeQuickItem {
		uid: relay.serviceUid + "/State"
	}

	readonly property DataPoint _relayFunction: DataPoint {
		source: relay.relayIndex === 0
			 ? "com.victronenergy.settings/Settings/Relay/Function"
			 : "com.victronenergy.settings/Settings/Relay/%1/Function".arg(model.index)
	}

	readonly property bool _valid: deviceInstance.value !== undefined
	on_ValidChanged: {
		if (!!Global.relays) {
			if (_valid) {
				Global.relays.addRelay(relay)
			} else {
				Global.relays.removeRelay(relay)
			}
		}
	}
}
