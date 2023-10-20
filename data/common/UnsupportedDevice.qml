/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: unsupportedDevice

	onValidChanged: {
		if (!!Global.unsupportedDevices) {
			if (valid) {
				Global.unsupportedDevices.model.addDevice(unsupportedDevice)
			} else {
				Global.unsupportedDevices.model.removeDevice(unsupportedDevice)
			}
		}
	}
}
