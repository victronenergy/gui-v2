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
			uids: ["dbus/com.victronenergy.system/Relay"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: QtObject {
			id: relay

			property string uid: model.uid
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
