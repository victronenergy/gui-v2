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
		QuantityObject { object: aggregate; unit: Global.systemSettings.volumeUnit }
	}

	onClicked: Global.openDevicePage(root.device.serviceUid)

	VeQuickItem {
		id: aggregate
		uid: root.device.serviceUid + "/Aggregate"
	}
}
