/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Component dcLoadComponent: Component {
		MockDevice {
			id: dcLoad

			property real voltage: Math.random() * 10
			property real current: Math.random() * 10
			readonly property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current

			serviceUid: "mock/com.victronenergy.dcload.ttyUSB" + deviceInstance
			name: "DCLoad" + deviceInstance

			Component.onCompleted: {
				Global.dcLoads.model.addDevice(dcLoad)
			}
		}
	}

	Component.onCompleted: {
		for (let i = 0; i < 2; ++i) {
			dcLoadComponent.createObject(root)
		}
	}
}
