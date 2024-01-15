/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: pulseMeter

	readonly property real aggregate: _aggregate.value === undefined ? -1 : _aggregate.value

	readonly property VeQuickItem _aggregate: VeQuickItem {
		uid: pulseMeter.serviceUid + "/Aggregate"
	}

	onValidChanged: {
		if (!!Global.pulseMeters) {
			if (valid) {
				Global.pulseMeters.model.addDevice(pulseMeter)
			} else {
				Global.pulseMeters.model.removeDevice(pulseMeter)
			}
		}
	}
}
