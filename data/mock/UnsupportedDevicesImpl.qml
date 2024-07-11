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
		unsupportedComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.unsupported.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component unsupportedComponent: Component {
		UnsupportedDevice {
			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Unsupported %1".arg(deviceInstance))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
