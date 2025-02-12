/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	secondaryText: connected.value === 1 ? "" : CommonWords.not_connected
	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue
		QuantityObject { object: connected.value === 1 ? totalPower : null; unit: VenusOS.Units_Watt }
	}

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
