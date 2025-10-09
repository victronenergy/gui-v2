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

	property string bindPrefix

	serviceUid: bindPrefix

	settingsModel: VisibleItemModel {
		ListText {
			text: CommonWords.status
			dataItem.uid: root.bindPrefix + "/Status"
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

		ListTemperature {
			text: CommonWords.temperature
			dataItem.uid: bindPrefix + "/Temperature"
			precision: 0
		}

		ListQuantity {
			//% "Humidity"
			text: qsTrId("temperature_humidity")
			dataItem.uid: bindPrefix + "/Humidity"
			unit: VenusOS.Units_Percentage
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Pressure"
			text: qsTrId("temperature_pressure")
			dataItem.uid: bindPrefix + "/Pressure"
			unit: VenusOS.Units_Hectopascal
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "PM2.5"
			text: qsTrId("temperature_pm25")
			dataItem.uid: bindPrefix + "/PM25"
			unit: VenusOS.Units_MicrogramPerCubicMeter
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "CO₂"
			text: qsTrId("temperature_co2")
			dataItem.uid: bindPrefix + "/CO2"
			unit: VenusOS.Units_PartsPerMillion
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "VOC index"
			text: qsTrId("temperature_voc")
			dataItem.uid: bindPrefix + "/VOC"
			unit: VenusOS.Units_None
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "NOx index"
			text: qsTrId("temperature_nox")
			dataItem.uid: bindPrefix + "/NOX"
			unit: VenusOS.Units_None
			preferredVisible: dataItem.valid
		}

		ListQuantity {
			//% "Luminosity"
			text: qsTrId("temperature_luminosity")
			dataItem.uid: bindPrefix + "/Luminosity"
			unit: VenusOS.Units_Lux
			preferredVisible: dataItem.valid
		}

		ListItem {
			id: sensorBattery

			//% "Sensor battery"
			text: qsTrId("temperature_sensor_battery")
			preferredVisible: batteryVoltage.valid

			content.children: [
				QuantityLabel {
					id: batteryVoltageLabel
					anchors.verticalCenter: parent.verticalCenter
					font.pixelSize: Theme.font_size_body2
					value: batteryVoltage.value == undefined ? NaN : batteryVoltage.value
					unit: VenusOS.Units_Volt_DC
					VeQuickItem {
						id: batteryVoltage
						uid: bindPrefix + "/BatteryVoltage"
					}
				},
				Label {
					anchors.verticalCenter: parent.verticalCenter
					text: {
						if (lowBattery.valid) {
							const low = lowBattery.value === 1
							//% "Low"
							return low ? qsTrId("temperature_sensor_battery_status_low")
									   : CommonWords.ok
						} else {
							return ""
						}
					}
					color: lowBattery.value === 1 ? Theme.color_red : Theme.color_green
					font.pixelSize: Theme.font_size_body2
					verticalAlignment: Text.AlignVCenter

					VeQuickItem {
						id: lowBattery
						uid:  bindPrefix + "/Alarms/LowBattery"
					}
				}
			]
		}

		ListNavigation {
			text: CommonWords.setup
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensorSetup.qml",
						{ "title": text, "bindPrefix": root.bindPrefix })
			}
		}
	}

	VeQuickItem {
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}
}
