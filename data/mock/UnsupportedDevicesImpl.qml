/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		Global.unsupportedDevices.model.addDevice(unsupportedComponent.createObject(root))
	}

	property Component unsupportedComponent: Component {
		MockDevice {
			serviceUid: "mock/com.victronenergy.unsupported.ttyUSB" + deviceInstance
			name: "Unsupported" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
