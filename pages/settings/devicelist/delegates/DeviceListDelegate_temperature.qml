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

		// Show the overall air quality score if available, otherwise raw CO2/PM2.5,
		// otherwise show temperature/humidity
		QuantityObject {
			object: iaqs.valid ? iaqs : co2.value !== undefined ? co2 : temperature
			key: iaqs.valid ? "textValue" : "value"
			unit: iaqs.valid ? VenusOS.Units_None
					: co2.value !== undefined ? VenusOS.Units_PartsPerMillion
					: Services.settings.temperatureUnit
		}
		QuantityObject {
			object: co2.value !== undefined ? (iaqs.valid ? co2 : pm25) : humidity
			unit: co2.value === undefined ? VenusOS.Units_Percentage
					: iaqs.valid ? VenusOS.Units_PartsPerMillion
					: VenusOS.Units_MicrogramPerCubicMeter
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
		displayUnit: Units.unitToVeUnit(Services.settings.temperatureUnit)
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

	VeQuickItem {
		id: iaqs

		readonly property string textValue: valid
				//% "%1 (%2)"
				? qsTrId("temperature_air_quality_score_short").arg(value).arg(qualityLabel)
				: ""
		readonly property string qualityLabel: Services.environment.airQualityToText(value)

		uid: root.device.serviceUid + "/IAQS"
	}
}
