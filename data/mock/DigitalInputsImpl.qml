/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const inputCount = (Math.random() * 3) + 1
		for (let i = 0; i < inputCount; ++i) {
			const inputObj = inputComponent.createObject(root, {
				type: Math.random() * VenusOS.DigitalInput_Type_Generator,
				state: Math.random() * VenusOS.DigitalInput_State_Stopped
			})
			Global.digitalInputs.model.addDevice(inputObj)
		}
	}

	property Component inputComponent: Component {
		MockDevice {
			property int type
			property int state

			serviceUid: "mock/com.victronenergy.digitalinput.ttyUSB" + deviceInstance
			name: "DigitalInput" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
