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

	VeQuickItem {
		id: deviceInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	VeQuickItem {
		id: productId
		uid: root.bindPrefix + "/ProductId"
	}

	GradientListView {
		model: ObjectModel {

			ListQuantityItem {
				property var displayText: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1)
				//% "Irradiance"
				text: qsTrId("page_meteo_irradiance")
				dataItem.uid: bindPrefix + "/Irradiance"
				value: Units.getDisplayText(VenusOS.Units_WattsPerSquareMeter, dataItem.value, 1).number
				unit: VenusOS.Units_WattsPerSquareMeter
				precision: 1
			}

			ListTemperatureItem {
				//% "Cell temperature"
				text: qsTrId("page_meteo_cell_temperature")
				allowed: dataItem.isValid
				dataItem.uid: bindPrefix + "/CellTemperature"
				precision: 1
			}

			ListTemperatureItem {
				text: sensor2.dataItem.isValid
					//% "External temperature (1)"
					? qsTrId("page_meteo_external_temperature_1")
					//% "External temperature"
					: qsTrId("page_meteo_external_temperature")
				allowed: dataItem.isValid
				dataItem.uid: bindPrefix + "/ExternalTemperature"
				precision: 1
			}

			ListTemperatureItem {
				id: sensor2

				dataItem.uid: bindPrefix + "/ExternalTemperature2"
				//% "External temperature (2)"
				text: qsTrId("page_meteo_external_temperature_2")
				allowed: dataItem.isValid
				precision: 1
			}

			ListQuantityItem {
				dataItem.uid: bindPrefix + "/WindSpeed"
				//% "Wind speed"
				text: qsTrId("page_meteo_wind_speed")
				allowed: dataItem.isValid
				unit: VenusOS.Units_Speed_MetresPerSecond
				precision: 1
			}

			ListQuantityItem {
				dataItem.uid: bindPrefix + "/InstallationPower"
				//% "Installation Power"
				text: qsTrId("page_meteo_installation_power")
				allowed: dataItem.isValid
				unit: VenusOS.Units_Watt
				precision: 1
			}

			ListQuantityItem {
				dataItem.uid: bindPrefix + "/TodaysYield"
				//% "Today's yield"
				text: qsTrId("page_meteo_daily_yield")
				allowed: dataItem.isValid
				unit: VenusOS.Units_Energy_KiloWattHour
				precision: 1
			}

			ListItem {
				id: sensorBattery

				//% "Sensor battery"
				text: qsTrId("page_meteo_battery_voltage")
				allowed: defaultAllowed && batteryVoltage.isValid

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
							if (lowBattery.isValid) {
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

			ListNavigationItem {
				id: settingsMenu

				text: CommonWords.settings
				onClicked: Global.pageManager.pushPage("/pages/settings/devicelist/PageMeteoSettings.qml", {
														   "title": CommonWords.settings,
														   meteoSettingsPrefix: root.settingsPrefix
													   })
				allowed: productId.value === ProductInfo.ProductId_MeteoSensor_Imt
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/PageDeviceInfo.qml",
									{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
