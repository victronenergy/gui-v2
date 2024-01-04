/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const chargerCount = (Math.random() * 2) + 1
		for (let i = 0; i < chargerCount; ++i) {
			const chargerObj = chargerComponent.createObject(root, {
				state: Math.random() * VenusOS.System_State_EqualizationCharging
			})
			Global.chargers.model.addDevice(chargerObj)
		}
	}

	property Component chargerComponent: Component {
		MockDevice {
			property int state

			serviceUid: "mock/com.victronenergy.charger.ttyUSB" + deviceInstance
			name: "Charger" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
