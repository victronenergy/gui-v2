/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	title: tankDescription.description

	TankDescription {
		id: tankDescription
		device: Device { serviceUid: root.bindPrefix }
	}

	GradientListView {
		model: ObjectModel {
			ListText {
				text: CommonWords.status
				dataItem.uid: root.bindPrefix + "/Status"
				secondaryText: Global.tanks.statusToText(dataItem.value)
			}

			ListQuantity {
				//% "Level"
				text: qsTrId("devicelist_tanksensor_level")
				dataItem.uid: root.bindPrefix + "/Level"
				unit: VenusOS.Units_Percentage
			}

			ListQuantity {
				//% "Remaining"
				text: qsTrId("devicelist_tanksensor_remaining")
				dataItem.uid: root.bindPrefix + "/Remaining"
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMeter)
				dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
				unit: Global.systemSettings.volumeUnit
			}

			ListTemperature {
				text: CommonWords.temperature
				dataItem.uid: root.bindPrefix + "/Temperature"
				preferredVisible: dataItem.isValid
			}

			ListQuantity {
				//% "Sensor battery"
				text: qsTrId("devicelist_tanksensor_sensor_battery")
				dataItem.uid: root.bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt_DC
				preferredVisible: dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.low_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/Low/State"
				preferredVisible: dataItem.isValid
			}

			ListAlarm {
				text: CommonWords.high_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/High/State"
				preferredVisible: dataItem.isValid
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
