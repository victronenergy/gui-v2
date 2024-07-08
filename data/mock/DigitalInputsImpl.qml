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
			const inputObj = inputComponent.createObject(root, {
				type: Math.random() * VenusOS.DigitalInput_Type_Generator,
				state: Math.random() * VenusOS.DigitalInput_State_Stopped
			})
		}
	}

	property Component inputComponent: Component {
		DigitalInput {
			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.digitalinput.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_customName.setValue("Digital input %1".arg(deviceInstanceNum))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
