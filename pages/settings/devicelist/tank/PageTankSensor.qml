/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMeter)
				dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
				unit: Global.systemSettings.volumeUnit
			}

			ListTemperatureItem {
				text: CommonWords.temperature
				dataItem.uid: root.bindPrefix + "/Temperature"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListQuantityItem {
				//% "Sensor battery"
				text: qsTrId("devicelist_tanksensor_sensor_battery")
				dataItem.uid: root.bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt_DC
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/Low/State"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/High/State"
				allowed: defaultAllowed && dataItem.isValid
			}

			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
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
