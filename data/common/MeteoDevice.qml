/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Device {
	id: meteoDevice

	readonly property real irradiance: _irradiance.value === undefined ? NaN : _irradiance.value

	readonly property VeQuickItem _irradiance: VeQuickItem {
		uid: meteoDevice.serviceUid + "/Irradiance"
	}

	onValidChanged: {
		if (!!Global.meteoDevices) {
			if (_valid) {
				Global.meteoDevices.model.addDevice(meteoDevice)
			} else {
				Global.meteoDevices.model.removeDevice(meteoDevice)
			}
		}
	}
}
