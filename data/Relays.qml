/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
//import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	property var _relays: []

	function _getRelays() {
		const childIds = [] // veRelay.childIds

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
/*
	VeQuickItem {
		id: veRelay
		uid: "dbus/com.victronenergy.system/Relay"
	}

	Connections {
		target: veRelay
		function onChildIdsChanged() { Qt.callLater(_getRelays) }
		Component.onCompleted: _getRelays()
	}
*/
	Instantiator {
		model: _relays
		delegate: QtObject {
			id: relay

			property string uid: modelData
			property int state: -1

			function setState(newState) {
//				_state.setValue(newState)
			}

			property bool _valid: state >= 0
			on_ValidChanged: {
				const index = Utils.findIndex(root.model, relay)
				if (_valid && index < 0) {
					root.model.append({ relay: relay })
				} else if (!_valid && index >= 0) {
					root.model.remove(index)
				}
			}
/*
			property VeQuickItem _state: VeQuickItem {
				uid: veRelay.uid + "/" + relay.uid + "/State"
				onValueChanged: relay.state = value === undefined ? -1 : value
			}
*/
		}
	}
}
