/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Units

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
				visible: defaultVisible && dataItem.isValid
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
				visible: defaultVisible && dataItem.isValid
			}

			ListQuantityItem {
				//% "Pressure"
				text: qsTrId("temperature_pressure")
				dataItem.uid: bindPrefix + "/Pressure"
				unit: VenusOS.Units_Hectopascal
				visible: defaultVisible && dataItem.isValid
			}

			ListQuantityItem {
				//% "Sensor battery"
				text: qsTrId("temperature_sensor_battery")
				dataItem.uid: bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataItem.isValid
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
