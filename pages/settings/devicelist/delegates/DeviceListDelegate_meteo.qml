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

		QuantityObject { object: estimatedPower; unit: VenusOS.Units_Watt }
		QuantityObject { object: todaysYield; unit: VenusOS.Units_Energy_KiloWattHour }
		QuantityObject { object: irradiance; unit: VenusOS.Units_WattsPerSquareMetre }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteo.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: estimatedPower
		uid: root.device.serviceUid + "/InstallationPower"
	}
	VeQuickItem {
		id: todaysYield
		uid: root.device.serviceUid + "/TodaysYield"
	}
	VeQuickItem {
		id: irradiance
		uid: root.device.serviceUid + "/Irradiance"
	}
}
