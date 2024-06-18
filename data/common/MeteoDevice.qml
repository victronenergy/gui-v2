/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: meteoDevice

	readonly property real irradiance: _irradiance.value === undefined ? NaN : _irradiance.value

	readonly property VeQuickItem _irradiance: VeQuickItem {
		uid: meteoDevice.serviceUid + "/Irradiance"
	}

	onValidChanged: {
		if (!!Global.meteoDevices) {
			if (valid) {
				Global.meteoDevices.model.addDevice(meteoDevice)
			} else {
				Global.meteoDevices.model.removeDevice(meteoDevice.serviceUid)
			}
		}
	}
}
