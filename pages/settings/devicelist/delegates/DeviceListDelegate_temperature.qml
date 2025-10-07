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

		// Show air quality data if CO2 is available, otherwise show temperature/humidity
		QuantityObject {
			object: co2.value !== undefined ? co2 : temperature
			unit: co2.value !== undefined ? VenusOS.Units_PartsPerMillion : Global.systemSettings.temperatureUnit
		}
		QuantityObject {
			object: co2.value !== undefined ? pm25 : humidity
			unit: co2.value !== undefined ? VenusOS.Units_MicrogramPerCubicMeter : VenusOS.Units_Percentage
		}
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

	VeQuickItem {
		id: co2
		uid: root.device.serviceUid + "/CO2"
	}

	VeQuickItem {
		id: pm25
		uid: root.device.serviceUid + "/PM25"
	}
}
