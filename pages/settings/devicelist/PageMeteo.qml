/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix
	readonly property string settingsPrefix: Global.systemSettings.serviceUid + "/Settings/Service/meteo/" + deviceInstance.value

	title: device.name

	Device {
		id: device
		serviceUid: root.bindPrefix
	}

	VeQuickItem {
		id: deviceInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	GradientListView {
		model: VisibleItemModel {

			ListQuantity {
				property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1)
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				dataItem.uid: bindPrefix + "/Irradiance"
				value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1).number
				unit: VenusOS.Units_WattsPerSquareMeter
				precision: 1
			}

			ListTemperature {
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/CellTemperature"
				precision: 1
			}

			ListTemperature {
				text: sensor2.dataItem.valid
					//% "External temperature (1)"
					? qsTrId("page_meteo_external_temperature_1")
					//% "External temperature"
					: qsTrId("page_meteo_external_temperature")
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/ExternalTemperature"
				precision: 1
			}

			ListTemperature {
				id: sensor2

				dataItem.uid: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				preferredVisible: dataItem.valid
				precision: 1
			}

			ListQuantity {
				dataItem.uid: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Speed_MetresPerSecond
				precision: 1
			}

			ListQuantity {
				dataItem.uid: bindPrefix + "/WindDirection"
				//% "Wind direction"
				text: qsTrId("page_meteo_wind_direction")
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_CardinalDirection
			}

			ListQuantity {
				dataItem.uid: bindPrefix + "/InstallationPower"
				//% "Installation Power"
				text: qsTrId("page_meteo_installation_power")
				preferredVisible: dataItem.valid
				unit: VenusOS.Units_Watt
				precision: 1
			}

			ListQuantity {
				dataItem.uid: bindPrefix + "/TodaysYield"
				//% "Today's yield"
				text: qsTrId("page_meteo_daily_yield")
				preferredVisible: dataItem.alid
				unit: VenusOS.Units_Energy_KiloWattHour
				precision: 1
			}

			ListItem {
				id: sensorBattery

				//% "Sensor battery"
				text: qsTrId("page_meteo_battery_voltage")
				preferredVisible: batteryVoltage.valid

				content.children: [
					QuantityLabel {
						id: batteryVoltageLabel
						anchors.verticalCenter: parent.verticalCenter
						font.pixelSize: Theme.font_size_body2
						value: batteryVoltage.value === undefined ? NaN : batteryVoltage.value
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
								return low ? qsTrId("meteo_sensor_battery_status_low")
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
				id: settingsMenu

				text: CommonWords.settings
				onClicked: Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteoSettings.qml", {
														   "title": CommonWords.settings,
														   meteoSettingsPrefix: root.settingsPrefix
													   })
				preferredVisible: productId.value === ProductInfo.ProductId_MeteoSensor_Imt
			}

			ListNavigation {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
									{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
