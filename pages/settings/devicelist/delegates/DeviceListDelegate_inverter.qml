/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue
		QuantityObject { object: inverter.currentPhase; key: "power"; unit: inverter.currentPhase.powerUnit }
	}

	onClicked: Global.openDevicePage(root.device.serviceUid, { "title": text })

	Inverter {
		id: inverter
		serviceUid: root.device.serviceUid
	}
}
