/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		for (let i = 0; i < relayObjects.count; ++i) {
			Global.relays.addRelay(relayObjects.objectAt(i))
		}
	}

	property Instantiator relayObjects: Instantiator {
		model: 3

		delegate: QtObject {
			id: relay

			function _reloadRelayFunction() {
				const uid = model.index === 0
						  ? "com.victronenergy.settings/Settings/Relay/Function"
						  : "com.victronenergy.settings/Settings/Relay/%1/Function".arg(model.index)
				relayFunction = Global.mockDataSimulator.mockDataValues[uid] || -1
			}

			property int state: model.index % 2 == 0 ? VenusOS.Relays_State_Inactive : VenusOS.Relays_State_Active
			property int relayFunction
			readonly property string name: Global.relays.relayName(model.index)

			readonly property Timer _functionUpdater: Timer {
				running: Global.mockDataSimulator.timersActive
				interval: 3000
				onTriggered: _reloadRelayFunction()
			}

			function setState(s) {
				state = s
			}

			onRelayFunctionChanged: {
				Global.relays.relayFunctionChanged(relay)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
