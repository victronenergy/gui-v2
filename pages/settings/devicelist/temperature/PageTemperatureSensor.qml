/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: temperatureType
		uid: bindPrefix + "/TemperatureType"
	}

	VeQuickItem {
		id: deviceInstance
		uid: bindPrefix + "/DeviceInstance"
	}

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				text: CommonWords.status
				dataItem.uid: root.bindPrefix + "/Status"
				allowed: defaultAllowed && dataItem.isValid
				secondaryText: {
					switch (dataItem.value) {
					case 0:
						return CommonWords.ok
					case 1:
						return CommonWords.disconnected
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

			ListTemperatureItem {
				text: CommonWords.temperature
				dataItem.uid: bindPrefix + "/Temperature"
			}

			ListQuantityItem {
				//% "Humidity"
				text: qsTrId("temperature_humidity")
				dataItem.uid: bindPrefix + "/Humidity"
				unit: VenusOS.Units_Percentage
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				//% "Pressure"
				text: qsTrId("temperature_pressure")
				dataItem.uid: bindPrefix + "/Pressure"
				unit: VenusOS.Units_Hectopascal
				allowed: defaultAllowed && dataItem.isValid
			}

			ListItem {
				id: sensorBattery

				//% "Sensor battery"
				text: qsTrId("temperature_sensor_battery")
				allowed: defaultAllowed && batteryVoltage.isValid

				content.children: [
					QuantityLabel {
						id: batteryVoltageLabel
						anchors.verticalCenter: parent.verticalCenter
						font.pixelSize: Theme.font_size_body2
						value: batteryVoltage.value
						unit: VenusOS.Units_Volt
						precision: 2
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

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/temperature/PageTemperatureSensorSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
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
