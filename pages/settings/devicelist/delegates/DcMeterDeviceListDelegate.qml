/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: [
		{ unit: VenusOS.Units_Volt_DC, value: voltage.value },
		{ unit: VenusOS.Units_Amp, value: current.value },
		{ unit: VenusOS.Units_Watt, value: power.value }
	]

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/dc-in/PageDcMeter.qml",
				{ bindPrefix : root.device.serviceUid })
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
