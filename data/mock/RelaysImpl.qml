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
			property int state: model.index % 2 == 0 ? VenusOS.Relays_State_Inactive : VenusOS.Relays_State_Active

			function setState(s) {
				state = s
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
