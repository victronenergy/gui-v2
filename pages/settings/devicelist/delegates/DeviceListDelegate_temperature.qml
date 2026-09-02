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
					: Global.systemSettings.temperatureUnit
			valueColor: iaqs.valid ? iaqs.qualityColor : Theme.color_font_primary
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

	VeQuickItem {
		id: iaqs
		uid: root.device.serviceUid + "/IAQS"

		readonly property string textValue: valid
				//% "%1 (%2)"
				? qsTrId("temperature_air_quality_score_short").arg(value).arg(qualityLabel)
				: ""
		readonly property string qualityLabel: {
			if (!valid) {
				return ""
			}
			if (value > 90) {
				//% "Excellent"
				return qsTrId("temperature_air_quality_excellent")
			}
			if (value > 80) {
				//% "Good"
				return qsTrId("temperature_air_quality_good")
			}
			if (value > 50) {
				//% "Fair"
				return qsTrId("temperature_air_quality_fair")
			}
			if (value >= 10) {
				//% "Poor"
				return qsTrId("temperature_air_quality_poor")
			}
			//% "Very poor"
			return qsTrId("temperature_air_quality_very_poor")
		}
		readonly property color qualityColor: {
			if (!valid) {
				return Theme.color_font_primary
			}
			if (value > 80) {
				return Theme.color_green
			}
			if (value > 50) {
				return Theme.color_orange
			}
			return Theme.color_red
		}
	}
}
