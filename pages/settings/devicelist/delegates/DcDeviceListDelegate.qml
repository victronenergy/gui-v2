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
		QuantityObject { object: voltage; unit: VenusOS.Units_Volt_DC }
		QuantityObject { object: current; unit: VenusOS.Units_Amp }
		QuantityObject { object: power; unit: VenusOS.Units_Watt }
	}

	onClicked: {
		if (BackendConnection.serviceTypeFromUid(device.serviceUid) === "dcdc") {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcDcConverter.qml",
					{ "bindPrefix": device.serviceUid })
		} else {
			Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
					{ "bindPrefix": device.serviceUid })
		}
	}

	VeQuickItem {
		id: voltage
		uid: root.device.serviceUid + "/Dc/0/Voltage"
	}

	VeQuickItem {
		id: current
		uid: root.device.serviceUid + "/Dc/0/Current"
	}

	VeQuickItem {
		id: power
		uid: root.device.serviceUid + "/Dc/0/Power"
	}
}
