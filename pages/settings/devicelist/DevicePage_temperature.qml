/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a temperature device.
*/
DevicePage {
	id: root

	settingsModel: VisibleItemModel {
		ListText {
			text: CommonWords.status
			dataItem.uid: root.serviceUid + "/Status"
			preferredVisible: dataItem.valid
			secondaryText: {
				switch (dataItem.value) {
				case 0:
					return CommonWords.ok
				case 1:
					return CommonWords.open_circuit
				case 2:
					//% "Short circuited"
					return qsTrId("temperature_short_circuited")
				case 3:
					//% "Reverse polarity"
					return qsTrId("temperature_reverse_polarity")
				case 5:
					//% "Sensor battery low"
					return qsTrId("temperature_sensor_battery_low")
				case 4: // status = Unknown
				default:
					return CommonWords.unknown_status
				}
			}
		}

		ListText {
			readonly property string qualityLabel: Global.environmentInputs.airQualityToText(dataItem.value)

			//% "Air quality"
			text: qsTrId("temperature_air_quality")
			dataItem.uid: root.serviceUid + "/IAQS"
			preferredVisible: dataItem.valid
			secondaryText: dataItem.valid
					//% "%1/100 (%2)"
					? qsTrId("temperature_air_quality_score").arg(dataItem.value).arg(qualityLabel)
					: ""
		}

		ListTemperature {
			text: CommonWords.temperature
			dataItem.uid: root.serviceUid + "/Temperature"
			decimals: 0
		}

		ListQuantity {
			//% "Humidity"
			text: qsTrId("temperature_humidity")
			dataItem.uid: root.serviceUid + "/Humidity"
			unit: VenusOS.Units_Percentage
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Pressure"
			text: qsTrId("temperature_pressure")
			dataItem.uid: root.serviceUid + "/Pressure"
			unit: VenusOS.Units_Hectopascal
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "PM2.5"
			text: qsTrId("temperature_pm25")
			dataItem.uid: root.serviceUid + "/PM25"
			unit: VenusOS.Units_MicrogramPerCubicMeter
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "CO₂"
			text: qsTrId("temperature_co2")
			dataItem.uid: root.serviceUid + "/CO2"
			unit: VenusOS.Units_PartsPerMillion
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "VOC index"
			text: qsTrId("temperature_voc")
			dataItem.uid: root.serviceUid + "/VOC"
			unit: VenusOS.Units_None
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "NOx index"
			text: qsTrId("temperature_nox")
			dataItem.uid: root.serviceUid + "/NOX"
			unit: VenusOS.Units_None
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Luminosity"
			text: qsTrId("temperature_luminosity")
			dataItem.uid: root.serviceUid + "/Luminosity"
			unit: VenusOS.Units_Lux
			preferredVisible: dataItem.valid
		}

		ListQuantityGroup {
			id: sensorBattery

			//% "Sensor battery"
			text: qsTrId("temperature_sensor_battery")
			preferredVisible: batteryVoltage.valid
			model: QuantityObjectModel {
				filterType: QuantityObjectModel.HasValue

				QuantityObject { object: batteryVoltage; unit: VenusOS.Units_Volt_DC }
				QuantityObject {
					object: lowBattery.valid ? lowBattery : null
					key: "textValue"
					unit: VenusOS.Units_None
					valueColor: lowBattery.textColor
				}
			}

			VeQuickItem {
				id: batteryVoltage
				uid: root.serviceUid + "/BatteryVoltage"
			}
			VeQuickItem {
				id: lowBattery

				readonly property string textValue: {
					if (valid) {
						//% "Low"
						return value === 1 ? qsTrId("temperature_sensor_battery_status_low") : CommonWords.ok
					} else {
						return ""
					}
				}
				readonly property color textColor: value === 1 ? Theme.color_red : Theme.color_green

				uid: root.serviceUid + "/Alarms/LowBattery"
			}
		}

		ListNavigation {
			text: CommonWords.setup
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensorSetup.qml",
						{ "title": text, "bindPrefix": root.serviceUid })
			}
		}
	}

	VeQuickItem {
		id: temperatureType
		uid: root.serviceUid + "/TemperatureType"
	}
}
