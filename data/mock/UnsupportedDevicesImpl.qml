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
		unsupportedComponent.createObject(root)
	}

	property Component unsupportedComponent: Component {
		UnsupportedDevice {
			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.unsupported.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_customName.setValue("Unsupported %1".arg(deviceInstanceNum))
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
