/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const multiRsDeviceObj = multiRsDeviceComponent.createObject(root, {
			state: Math.random() * VenusOS.System_State_EqualizationCharging
		})
		Global.multiRsDevices.model.addDevice(multiRsDeviceObj)
	}

	property Component multiRsDeviceComponent: Component {
		MockDevice {
			property int state

			serviceUid: "mock/com.victronenergy.multi.ttyUSB" + deviceInstance
			name: "MultiRsDevice" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
