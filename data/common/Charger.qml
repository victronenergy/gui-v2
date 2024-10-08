/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: charger

	readonly property int state: _state.isValid ? _state.value : -1

	readonly property VeQuickItem _state: VeQuickItem {
		uid: charger.serviceUid + "/State"
	}

	onValidChanged: {
		if (!!Global.chargers) {
			if (valid) {
				Global.chargers.model.addDevice(charger)
			} else {
				Global.chargers.model.removeDevice(charger.serviceUid)
			}
		}
	}
}
