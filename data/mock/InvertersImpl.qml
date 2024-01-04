/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const inverterCount = (Math.random() * 3) + 1
		for (let i = 0; i < inverterCount; ++i) {
			const inverterObj = inverterComponent.createObject(root)
			Global.inverters.model.addDevice(inverterObj)
		}
	}

	property Component inverterComponent: Component {
		MockDevice {
			property var currentPhase: acOutL2
			property var acOutL1: QtObject {
				property real voltage: Math.random() * 10
				property real current: Math.random() * 10
				property real power: Math.random() * 10
				property int powerUnit: VenusOS.Units_Watt
			}
			property var acOutL2: QtObject {
				property real voltage: Math.random() * 10
				property real current: Math.random() * 10
				property real power: Math.random() * 10
				property int powerUnit: VenusOS.Units_Watt
			}
			property var acOutL3: QtObject {
				property real voltage: Math.random() * 10
				property real current: Math.random() * 10
				property real power: Math.random() * 10
				property int powerUnit: VenusOS.Units_Watt
			}

			serviceUid: "mock/com.victronenergy.inverter.ttyUSB" + deviceInstance
			name: "Inverter" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
