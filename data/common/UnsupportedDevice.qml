/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: unsupportedDevice

	onValidChanged: {
		if (!!Global.unsupportedDevices) {
			if (valid) {
				Global.unsupportedDevices.model.addDevice(unsupportedDevice)
			} else {
				Global.unsupportedDevices.model.removeDevice(unsupportedDevice.serviceUid)
			}
		}
	}
}
