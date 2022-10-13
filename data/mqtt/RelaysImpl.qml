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
		let relayIds = []
		for (let i = 0; i < veRelay.count; ++i) {
			const uid = veRelay.objectAt(i).uid
			const id = uid.substring(uid.lastIndexOf('/') + 1)
			if (!isNaN(parseInt(id))) {
				relayIds.push(uid)
			}
		}
		if (Utils.arrayCompare(_relays, relayIds) !== 0) {
			_relays = relayIds
		}
	}

	property Instantiator veRelay:  Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/system/0/Relay"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			property var uid: model.uid
		}

		onCountChanged: Qt.callLater(root._getRelays)
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
				uid: relay.uid + "/State"
				onValueChanged: relay.state = value === undefined ? -1 : value
			}
		}
	}
}
