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
		const inputCount = (Math.random() * 3) + 1
		for (let i = 0; i < inputCount; ++i) {
			const deviceInstanceNum = mockDeviceCount++
			const inputObj = inputComponent.createObject(root, {
				serviceUid: "mock/com.victronenergy.digitalinput.ttyUSB" + deviceInstanceNum,
				deviceInstance: deviceInstanceNum,
			})
		}
	}

	property Component inputComponent: Component {
		Device {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Digital input %1".arg(deviceInstance))
				Global.mockDataSimulator.setMockValue(serviceUid + "/Type", Math.floor(Math.random() * VenusOS.DigitalInput_Type_Generator))
				Global.mockDataSimulator.setMockValue(serviceUid + "/State", Math.floor(Math.random() * VenusOS.DigitalInput_State_Stopped))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
