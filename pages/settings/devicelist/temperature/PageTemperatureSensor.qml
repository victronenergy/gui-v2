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

	VeQuickItem {
		id: luminosityItem
		uid: bindPrefix + "/Luminosity"
	}
	VeQuickItem {
		id: nOXItem
		uid: bindPrefix + "/NOX"
	}
	VeQuickItem {
		id: vOCItem
		uid: bindPrefix + "/VOC"
	}
	VeQuickItem {
		id: cO2Item
		uid: bindPrefix + "/CO2"
	}
	VeQuickItem {
		id: pM25Item
		uid: bindPrefix + "/PM25"
	}
	VeQuickItem {
		id: pressureItem
		uid: bindPrefix + "/Pressure"
	}
	VeQuickItem {
		id: humidityItem
		uid: bindPrefix + "/Humidity"
	}
	VeQuickItem {
		id: statusItem
		uid: root.bindPrefix + "/Status"
	}
	VeQuickItem {
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}

	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			preferredVisible: statusItem.valid
			ListText {
				text: CommonWords.status
				dataItem.uid: root.bindPrefix + "/Status"
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
		}

		DelegateComponent {
			ListTemperature {
				text: CommonWords.temperature
				dataItem.uid: bindPrefix + "/Temperature"
				decimals: 0
			}
		}

		DelegateComponent {
			preferredVisible: humidityItem.valid
			ListQuantity {
				//% "Humidity"
				text: qsTrId("temperature_humidity")
				dataItem.uid: bindPrefix + "/Humidity"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			preferredVisible: pressureItem.valid
			ListQuantity {
				//% "Pressure"
				text: qsTrId("temperature_pressure")
				dataItem.uid: bindPrefix + "/Pressure"
				unit: VenusOS.Units_Hectopascal
			}
		}

		DelegateComponent {
			preferredVisible: pM25Item.valid
			ListQuantity {
				//% "PM2.5"
				text: qsTrId("temperature_pm25")
				dataItem.uid: bindPrefix + "/PM25"
				unit: VenusOS.Units_MicrogramPerCubicMeter
			}
		}

		DelegateComponent {
			preferredVisible: cO2Item.valid
			ListQuantity {
				//% "CO₂"
				text: qsTrId("temperature_co2")
				dataItem.uid: bindPrefix + "/CO2"
				unit: VenusOS.Units_PartsPerMillion
			}
		}

		DelegateComponent {
			preferredVisible: vOCItem.valid
			ListQuantity {
				//% "VOC index"
				text: qsTrId("temperature_voc")
				dataItem.uid: bindPrefix + "/VOC"
				unit: VenusOS.Units_None
			}
		}

		DelegateComponent {
			preferredVisible: nOXItem.valid
			ListQuantity {
				//% "NOx index"
				text: qsTrId("temperature_nox")
				dataItem.uid: bindPrefix + "/NOX"
				unit: VenusOS.Units_None
			}
		}

		DelegateComponent {
			preferredVisible: luminosityItem.valid
			ListQuantity {
				//% "Luminosity"
				text: qsTrId("temperature_luminosity")
				dataItem.uid: bindPrefix + "/Luminosity"
				unit: VenusOS.Units_Lux
			}
		}

		DelegateComponent {
			id: batteryVoltageDC
			dataItem: VeQuickItem { uid: bindPrefix + "/BatteryVoltage" }
			preferredVisible: batteryVoltageDC.dataItem.valid
			ListQuantityGroup {
				id: sensorBattery

				//% "Sensor battery"
				text: qsTrId("temperature_sensor_battery")
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
					uid: bindPrefix + "/BatteryVoltage"
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

					uid: bindPrefix + "/Alarms/LowBattery"
				}
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensorSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}