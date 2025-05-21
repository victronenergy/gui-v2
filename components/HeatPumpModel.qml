/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ServiceDeviceModel {
	id: root

	required property int position

	serviceType: "heatpump"
	modelId: "heatpump"

	deviceDelegate: Device {
		id: device

		required property string uid
		readonly property bool positionMatched: valid && _position.valid && _position.value === root.position

		readonly property VeQuickItem _position: VeQuickItem {
			uid: device.serviceUid + "/Position"
		}

		serviceUid: uid
		onPositionMatchedChanged: {
			if (positionMatched) {
				root.addDevice(device)
			} else {
				root.removeDevice(device.serviceUid)
			}
		}
	}
}
