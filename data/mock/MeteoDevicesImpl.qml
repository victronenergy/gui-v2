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
		meteoComponent.createObject(root)
	}

	property Component meteoComponent: Component {
		MeteoDevice {
			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.meteo.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_customName.setValue("Meteo %1".arg(deviceInstanceNum))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
