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

		// For services without a /Position value, assume it is in the "input" position.
		readonly property bool positionMatched: root.position === VenusOS.AcPosition_AcOutput
				? valid && _position.valid && _position.value === VenusOS.AcPosition_AcOutput
				: valid && (!_position.valid || _position.value === VenusOS.AcPosition_AcInput)

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
