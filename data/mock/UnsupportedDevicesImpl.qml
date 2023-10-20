/*
** Copyright (C) 2023 Victron Energy B.V.
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
			serviceUid: "com.victronenergy.unsupported.ttyUSB" + deviceInstance
			name: "Unsupported" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
