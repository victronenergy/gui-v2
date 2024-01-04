/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		Global.motorDrives.model.addDevice(motorDriveComponent.createObject(root))
	}

	property Component motorDriveComponent: Component {
		MockDevice {
			property real motorRpm: 9000

			serviceUid: "mock/com.victronenergy.motordrive.ttyUSB" + deviceInstance
			name: "MotorDrive" + deviceInstance
		}
	}

	Component.onCompleted: {
		populate()
	}
}
