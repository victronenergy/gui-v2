/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property var _relays: []

	function _getRelays() {
		const childIds = veRelay.childIds

		let relayIds = []
		for (let i = 0; i < childIds.length; ++i) {
			let id = childIds[i]
			if (!isNaN(parseInt(id))) {
				relayIds.push(id)
			}
		}

		if (Utils.arrayCompare(_relays, relayIds) !== 0) {
			_relays = relayIds
		}
	}

	property VeQuickItem veRelay: VeQuickItem {
		uid: "dbus/com.victronenergy.system/Relay"
		onChildIdsChanged: Qt.callLater(_getRelays)
	}

	property Instantiator relayObjects: Instantiator {
		model: _relays
		delegate: QtObject {
			id: relay

			property string uid: modelData
			property int state: -1

			function setState(newState) {
				_state.setValue(newState)
			}

			property bool _valid: state >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(Global.relays.model, relay)
				if (_valid && index < 0) {
					Global.relays.addRelay(relay)
				} else if (!_valid && index >= 0) {
					Global.relays.removeRelay(index)
				}
			}

			property VeQuickItem _state: VeQuickItem {
				uid: veRelay.uid + "/" + relay.uid + "/State"
				onValueChanged: relay.state = value === undefined ? -1 : value
			}
		}
	}

	Component.onCompleted: {
		_getRelays()
	}
}
