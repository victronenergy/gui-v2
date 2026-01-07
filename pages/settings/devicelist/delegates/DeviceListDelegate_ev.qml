/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DeviceListDelegate {
	id: root

	quantityModel: QuantityObjectModel {
		filterType: QuantityObjectModel.HasValue

		QuantityObject { object: soc; unit: VenusOS.Units_Percentage }
		QuantityObject { object: range; key: "valueInMetres"; unit: VenusOS.Units_Altitude_Metre }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/ev/EvPage.qml", {
			bindPrefix: root.device.serviceUid
		})
	}

	VeQuickItem {
		id: soc
		uid: root.device.serviceUid + "/Soc"
	}

	VeQuickItem {
		id: range

		readonly property real valueInMetres: (value ?? 0) * 1000

		uid: root.device.serviceUid + "/RangeToGo"
	}
}
