/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount

	function populate(position) {
		const deviceInstanceNum = mockDeviceCount++
		const heatPump = heatPumpComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.heatpump.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
		BackendConnection.setMockValue(heatPump.serviceUid + "/Position", position)
	}

	property Component heatPumpComponent: Component {
		Device {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Heat Pump %1".arg(deviceInstance))
				_productId.setValue(0x01) // set a non-empty value so that PageAcIn.qml shows some content
				BackendConnection.setMockValue(serviceUid + "/Ac/Power", Math.random() * 100)
				BackendConnection.setMockValue(serviceUid + "/AllowedRoles", Global.acInputs.roles.map((r) => { return r.role }))
				BackendConnection.setMockValue(serviceUid + "/Role", "heatpump")
			}
		}
	}

	Component.onCompleted: {
		populate(VenusOS.AcPosition_AcInput)
		populate(VenusOS.AcPosition_AcOutput)
	}
}
