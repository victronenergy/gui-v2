/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	Provides a list of settings for a tank device.
*/
DevicePage {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: stateItem
		uid: root.bindPrefix + "/Alarms/High/State"
	}
	VeQuickItem {
		id: stateItem2
		uid: root.bindPrefix + "/Alarms/Low/State"
	}
	VeQuickItem {
		id: batteryVoltageItem
		uid: root.bindPrefix + "/BatteryVoltage"
	}
	VeQuickItem {
		id: temperatureItem
		uid: root.bindPrefix + "/Temperature"
	}

	title: tankDescription.description
	serviceUid: bindPrefix

	settingsModel: DelegateComponentModel {
		DelegateComponent {
			ListText {
				text: CommonWords.status
				dataItem.uid: root.bindPrefix + "/Status"
				secondaryText: Global.tanks.statusToText(dataItem.value)
			}
		}

		DelegateComponent {
			ListQuantity {
				//% "Level"
				text: qsTrId("devicelist_tanksensor_level")
				dataItem.uid: root.bindPrefix + "/Level"
				unit: VenusOS.Units_Percentage
			}
		}

		DelegateComponent {
			ListQuantity {
				//% "Remaining"
				text: qsTrId("devicelist_tanksensor_remaining")
				dataItem.uid: root.bindPrefix + "/Remaining"
				dataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Volume_CubicMetre)
				dataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.volumeUnit)
				unit: Global.systemSettings.volumeUnit
			}
		}

		DelegateComponent {
			preferredVisible: temperatureItem.valid
			ListTemperature {
				text: CommonWords.temperature
				dataItem.uid: root.bindPrefix + "/Temperature"
			}
		}

		DelegateComponent {
			preferredVisible: batteryVoltageItem.valid
			ListQuantity {
				//% "Sensor battery"
				text: qsTrId("devicelist_tanksensor_sensor_battery")
				dataItem.uid: root.bindPrefix + "/BatteryVoltage"
				unit: VenusOS.Units_Volt_DC
			}
		}

		DelegateComponent {
			preferredVisible: stateItem2.valid
			ListAlarm {
				text: CommonWords.low_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/Low/State"
			}
		}

		DelegateComponent {
			preferredVisible: stateItem.valid
			ListAlarm {
				text: CommonWords.high_level_alarm
				dataItem.uid: root.bindPrefix + "/Alarms/High/State"
			}
		}

		DelegateComponent {
			ListNavigation {
				text: CommonWords.setup
				onClicked: {
					Global.pageManager.pushPage("/pages/settings/devicelist/tank/PageTankSetup.qml",
							{ "title": text, "bindPrefix": root.bindPrefix })
				}
			}
		}
	}

	TankDescription {
		id: tankDescription
		device: Device { serviceUid: root.bindPrefix }
	}

}