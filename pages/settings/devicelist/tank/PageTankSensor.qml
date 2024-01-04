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
				dataItem.uid: root.bindPrefix + "/Status"
				secondaryText: Global.tanks.statusToText(dataItem.value)
			}

			ListQuantityItem {
				//% "Level"
				text: qsTrId("devicelist_tanksensor_level")
				dataItem.uid: root.bindPrefix + "/Level"
				unit: VenusOS.Units_Percentage
			}

			ListQuantityItem {
				//% "Remaining"
				text: qsTrId("devicelist_tanksensor_remaining")
				dataItem.uid: root.bindPrefix + "/Remaining"
				value: Units.convertVolumeForUnit(dataItem.value, Global.systemSettings.volumeUnit.value)
				unit: Global.systemSettings.volumeUnit.value
			}

			ListQuantityItem {
				text: CommonWords.temperature
				dataItem.uid: root.bindPrefix + "/Temperature"
				value: dataItem.isValid
					   ? Global.systemSettings.temperatureUnit.value === VenusOS.Units_Temperature_Celsius
						   ? dataItem.value
						   : Units.celsiusToFahrenheit(dataItem.value)
					   : NaN
				unit: Global.systemSettings.temperatureUnit.value
				visible: defaultVisible && dataItem.isValid
			}

			ListQuantityItem {
				//% "Sensor battery"
				text: qsTrId("devicelist_tanksensor_sensor_battery")
				dataItem.uid: root.bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt
				precision: 2
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/Low/State"
				visible: defaultVisible && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/High/State"
				visible: defaultVisible && dataItem.isValid
			}

			ListNavigationItem {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankSetup.qml",
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
