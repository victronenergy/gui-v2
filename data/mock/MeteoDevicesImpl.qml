/*
** Copyright (C) 2023 Victron Energy B.V.
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

			serviceUid: "com.victronenergy.meteo.ttyUSB" + deviceInstance
			name: "meteo" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
