/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount

	function populate() {
		const deviceInstanceNum = mockDeviceCount++
		for (let i = 0; i < 3; ++i) {
			const relay = relayComponent.createObject(root, {
				serviceUid: Global.system.serviceUid + "/Relay" + deviceInstanceNum,
				deviceInstance: deviceInstanceNum,
			})
			relay._veState.setValue(i % 2 == 0 ? VenusOS.Relays_State_Inactive : VenusOS.Relays_State_Active)
			relay._relayFunction.setValue(i == 0 ? VenusOS.Relay_Function_Manual : Math.floor(Math.random() * VenusOS.Relay_Function_Temperature))
		}
	}

	property Component relayComponent: Component {
		Relay {
			id: relay
		}
	}
}
