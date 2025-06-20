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
		MockManager.setValue(heatPump.serviceUid + "/Position", position)
	}

	property Component heatPumpComponent: Component {
		Device {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Heat Pump %1".arg(deviceInstance))
				_productId.setValue(0x01) // set a non-empty value so that PageAcIn.qml shows some content
				MockManager.setValue(serviceUid + "/Ac/Power", Math.random() * 100)
				MockManager.setValue(serviceUid + "/AllowedRoles", Global.acInputs.roles.map((r) => { return r.role }))
				MockManager.setValue(serviceUid + "/Role", "heatpump")
			}
		}
	}

	Component.onCompleted: {
		populate(VenusOS.AcPosition_AcInput)
		populate(VenusOS.AcPosition_AcOutput)
	}
}
