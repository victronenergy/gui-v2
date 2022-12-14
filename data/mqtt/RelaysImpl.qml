/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property Instantiator relayObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/system/0/Relay"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			id: relay

			readonly property string uid: model.uid
			readonly property int state: _state.value === undefined ? -1 : _state.value
			readonly property int relayFunction: _relayFunction.value === undefined ? -1 : _relayFunction.value
			readonly property string name: Global.relays.relayName(model.index)

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

			onRelayFunctionChanged: {
				Global.relays.relayFunctionChanged(relay)
			}

			property VeQuickItem _state: VeQuickItem {
				uid: relay.uid + "/State"
			}

			property VeQuickItem _relayFunction: VeQuickItem {
				uid: model.index === 0
					 ? "mqtt/settings/0/Settings/Relay/Function"
					 : "mqtt/settings/0/Settings/Relay/%1/Function".arg(model.index)
			}
		}
	}
}
