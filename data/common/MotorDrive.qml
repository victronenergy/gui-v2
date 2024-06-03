/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: motorDrive

	readonly property real motorRpm: _motorRpm.numberValue

	readonly property VeQuickItem _motorRpm: VeQuickItem {
		uid: motorDrive.serviceUid + "/Motor/RPM"
	}

	onValidChanged: {
		if (!!Global.motorDrives) {
			if (valid) {
				Global.motorDrives.model.addDevice(motorDrive)
			} else {
				Global.motorDrives.model.removeDevice(motorDrive)
			}
		}
	}
}
