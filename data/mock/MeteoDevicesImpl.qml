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
		meteoComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.meteo.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component meteoComponent: Component {
		Device {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Meteo %1".arg(deviceInstance))
				Global.mockDataSimulator.setMockValue(serviceUid + "/Irradiance", Math.random() * 100)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
