/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: acSystemDevice

	readonly property int state: _state.isValid ? _state.value : -1

	readonly property VeQuickItem _state: VeQuickItem {
		uid: acSystemDevice.serviceUid + "/State"
	}

	onValidChanged: {
		if (!!Global.acSystemDevices) {
			if (valid) {
				Global.acSystemDevices.model.addDevice(acSystemDevice)
			} else {
				Global.acSystemDevices.model.removeDevice(acSystemDevice.serviceUid)
			}
		}
	}
}
