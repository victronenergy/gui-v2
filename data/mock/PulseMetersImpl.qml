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
		pulseMeterComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.pulsemeter.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component pulseMeterComponent: Component {
		PulseMeter {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("PulseMeter %1".arg(deviceInstance))
				Global.mockDataSimulator.setMockValue(serviceUid + "/Aggregate", Math.random() * 100)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
