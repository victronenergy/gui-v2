/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const acSystemDeviceObj = acSystemDeviceComponent.createObject(root, {
			state: Math.random() * VenusOS.System_State_EqualizationCharging
		})
		Global.acSystemDevices.model.addDevice(acSystemDeviceObj)
	}

	property Component acSystemDeviceComponent: Component {
		MockDevice {
			property int state

			serviceUid: "mock/com.victronenergy.acsystem.ttyUSB" + deviceInstance
			name: "AcSystemDevice" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
