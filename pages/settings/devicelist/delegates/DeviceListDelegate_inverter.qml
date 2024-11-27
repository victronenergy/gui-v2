/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: [
		{ value: inverter.currentPhase.power, unit: inverter.currentPhase.powerUnit }
	]

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/inverter/PageInverter.qml",
				{ "title": text, bindPrefix : root.device.serviceUid })
	}

	Inverter {
		id: inverter
		serviceUid: root.device.serviceUid
	}
}
