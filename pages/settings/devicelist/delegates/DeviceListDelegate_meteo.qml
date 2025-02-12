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
		QuantityObject { object: irradiance; unit: VenusOS.Units_WattsPerSquareMeter }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteo.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: irradiance
		uid: root.device.serviceUid + "/Irradiance"
	}
}
