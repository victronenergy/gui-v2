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

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				text: CommonWords.status
				dataSource: root.bindPrefix + "/Status"
				secondaryText: Global.tanks.statusToText(dataValue)
			}

			ListQuantityItem {
				//% "Level"
				text: qsTrId("devicelist_tanksensor_level")
				dataSource: root.bindPrefix + "/Level"
				unit: VenusOS.Units_Percentage
			}

			ListQuantityItem {
				//% "Remaining"
				text: qsTrId("devicelist_tanksensor_remaining")
				dataSource: root.bindPrefix + "/Remaining"
				value: Units.convertVolumeForUnit(dataValue, Global.systemSettings.volumeUnit.value)
				unit: Global.systemSettings.volumeUnit.value
			}

			ListQuantityItem {
				text: CommonWords.temperature
				dataSource: root.bindPrefix + "/Temperature"
				value: dataValid
					   ? Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
						   ? dataValue
						   : Units.celsiusToFahrenheit(dataValue)
					   : NaN
				unit: Global.systemSettings.temperatureUnit.value
				visible: defaultVisible && dataValid
			}

			ListQuantityItem {
				//% "Sensor battery"
				text: qsTrId("devicelist_tanksensor_sensor_battery")
				dataSource: root.bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				text: CommonWords.low_level_alarm
				dataSource: root.bindPrefix + "/Alarms/Low/State"
				visible: defaultVisible && dataValid
			}

			ListAlarm {
				text: CommonWords.high_level_alarm
				dataSource: root.bindPrefix + "/Alarms/High/State"
				visible: defaultVisible && dataValid
			}

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/devicelist/tank/PageTankSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}

			ListNavigationItem {
				text: CommonWords.device_info_title
				onClicked: {
					Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/PageDeviceInfo.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}
}
