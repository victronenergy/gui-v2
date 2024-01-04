/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		Global.meteoDevices.model.addDevice(meteoComponent.createObject(root))
	}

	property Component meteoComponent: Component {
		MockDevice {
			property real irradiance: Math.random() * 500

			serviceUid: "mock/com.victronenergy.meteo.ttyUSB" + deviceInstance
			name: "meteo" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
