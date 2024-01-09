/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: input

	readonly property int type: _type.value === undefined ? -1 : _type.value
	readonly property int state: _state.value === undefined ? -1 : _state.value

	readonly property VeQuickItem _type: VeQuickItem {
		uid: input.serviceUid + "/Type"
	}

	readonly property VeQuickItem _state: VeQuickItem {
		uid: input.serviceUid + "/State"
	}

	onValidChanged: {
		if (!!Global.digitalInputs) {
			if (valid) {
				Global.digitalInputs.model.addDevice(input)
			} else {
				Global.digitalInputs.model.removeDevice(input)
			}
		}
	}
}
