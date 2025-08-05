/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ServiceDeviceModel {
	id: root

	required property int position

	deviceDelegate: Device {
		id: device

		required property string uid
		readonly property bool positionMatched: valid && _position.valid && _position.value === root.position
		property bool addedToModel

		readonly property VeQuickItem _position: VeQuickItem {
			uid: device.serviceUid + "/Position"
		}

		serviceUid: uid
		onPositionMatchedChanged: {
			if (positionMatched && !addedToModel) {
				root.addDevice(device)
				addedToModel = true
			} else if (!positionMatched && addedToModel) {
				root.removeDevice(device.serviceUid)
				addedToModel = false
			}
		}
	}
}
