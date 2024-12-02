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
		motorDriveComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.motordrive.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component motorDriveComponent: Component {
		Device {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Motor Drive %1".arg(deviceInstance))
				Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/RPM", Math.floor(Math.random() * 50))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
