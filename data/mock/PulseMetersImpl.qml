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
		pulseMeterComponent.createObject(root)
	}

	property Component pulseMeterComponent: Component {
		PulseMeter {
			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.pulsemeter.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_customName.setValue("PulseMeter %1".arg(deviceInstanceNum))
				_aggregate.setValue(Math.random() * 100)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
