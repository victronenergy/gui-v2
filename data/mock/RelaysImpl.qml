/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator relayObjects: Instantiator {
		model: 3

		delegate: MockDevice {
			id: relay

			function _reloadRelayFunction() {
				const uid = model.index === 0
						  ? Global.systemSettings.serviceUid + "/Settings/Relay/Function"
						  : Global.systemSettings.serviceUid + "/Settings/Relay/%1/Function".arg(model.index)
				const value = Global.mockDataSimulator.mockValue(uid)
				relayFunction = value === undefined ? -1 : value
			}

			property int state: model.index % 2 == 0 ? VenusOS.Relays_State_Inactive : VenusOS.Relays_State_Active
			property int relayFunction

			serviceUid: Global.system.serviceUid + "/Relay" + deviceInstance
			name: Global.relays.relayName(model.index)

			readonly property Timer _functionUpdater: Timer {
				running: Global.mockDataSimulator.timersActive
				interval: 3000
				onTriggered: _reloadRelayFunction()
			}

			function setState(s) {
				state = s
			}
		}

		onObjectAdded: function(index, object) {
			Global.relays.addRelay(object)
		}
	}
}
