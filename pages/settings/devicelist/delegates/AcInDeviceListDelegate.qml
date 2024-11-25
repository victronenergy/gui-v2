/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	secondaryText: connected.value === 1 ? "" : CommonWords.not_connected
	quantityModel: connected.value === 1 ? [ { value: totalPower.value, unit: VenusOS.Units_Watt } ] : null

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/ac-in/PageAcIn.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: connected
		uid: root.device.serviceUid + "/Connected"
	}

	VeQuickItem {
		id: totalPower
		uid: root.device.serviceUid + "/Ac/Power"
	}
}
