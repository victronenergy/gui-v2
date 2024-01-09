/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: multiRsDevice

	readonly property int state: _state.value === undefined ? -1 : _state.value

	readonly property VeQuickItem _state: VeQuickItem {
		uid: multiRsDevice.serviceUid + "/State"
	}

	onValidChanged: {
		if (!!Global.multiRsDevices) {
			if (valid) {
				Global.multiRsDevices.model.addDevice(multiRsDevice)
			} else {
				Global.multiRsDevices.model.removeDevice(multiRsDevice)
			}
		}
	}
}
