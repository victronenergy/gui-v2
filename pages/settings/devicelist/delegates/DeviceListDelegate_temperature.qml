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

		QuantityObject { object: temperature; unit: Global.systemSettings.temperatureUnit }
		QuantityObject { object: humidity; unit: VenusOS.Units_Percentage }
	}

	onClicked: {
		Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensor.qml",
				{ bindPrefix : root.device.serviceUid })
	}

	VeQuickItem {
		id: temperature
		uid: root.device.serviceUid + "/Temperature"
		sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Celsius)
		displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
	}

	VeQuickItem {
		id: humidity
		uid: root.device.serviceUid + "/Humidity"
	}
}
