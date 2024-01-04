/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import Victron.Utils

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

	readonly property VeQuickItem _relayFunction: VeQuickItem {
		uid: relay.relayIndex === 0
			 ? Global.systemSettings.serviceUid + "/Settings/Relay/Function"
			 : Global.systemSettings.serviceUid + "/Settings/Relay/%1/Function".arg(model.index)
	}

	onValidChanged: {
		if (!!Global.relays) {
			if (valid) {
				Global.relays.addRelay(relay)
			} else {
				Global.relays.removeRelay(relay)
			}
		}
	}
}
