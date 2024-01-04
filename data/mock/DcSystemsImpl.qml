/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Component dcSystemComponent: Component {
		MockDevice {
			id: dcSystem

			property real voltage: Math.random() * 10
			property real current: Math.random() * 10
			readonly property real power: isNaN(voltage) || isNaN(current) ? NaN : voltage * current

			serviceUid: "mock/com.victronenergy.dcsystem.ttyUSB" + deviceInstance
			name: "DCSystem" + deviceInstance

			Component.onCompleted: {
				Global.dcSystems.model.addDevice(dcSystem)
			}
		}
	}

	Component.onCompleted: {
		for (let i = 0; i < 2; ++i) {
			dcSystemComponent.createObject(root)
		}
	}
}
