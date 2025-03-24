/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	title: CommonWords.batteries

	GradientListView {
		header: SettingsColumn {
			width: parent ? parent.width : 0
			bottomPadding: spacing

			ListRadioButtonGroup {
				id: batteryMonitorRadioButtons

				//% "Battery monitor"
				text: qsTrId("settings_system_battery_monitor")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/BatteryService"
				//% "Unavailable monitor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_monitor")

				VeQuickItem {
					id: availableBatteryServices

					uid: Global.system.serviceUid + "/AvailableBatteryServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							batteryMonitorRadioButtons.optionModel = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			ListText {
				//% "Auto-selected"
				text: qsTrId("settings_system_auto_selected")
				dataItem.uid: Global.system.serviceUid + "/AutoSelectedBatteryService"
				preferredVisible: batteryMonitorRadioButtons.optionModel !== undefined
					&& batteryMonitorRadioButtons.currentIndex >= 0
					&& batteryMonitorRadioButtons.optionModel[batteryMonitorRadioButtons.currentIndex].value === "default"
			}
		}

		model: batteryModel
		delegate: SystemBatteryDelegate {}

		footer: SettingsColumn {
			width: parent ? parent.width : 0
			topPadding: spacing

			ListNavigation {
				//% "Battery measurements"
				text: qsTrId("settings_system_battery_measurements")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteryMeasurements.qml", { title: text })
			}
		}
	}

	SystemBatteryDeviceModel {
		id: batteryModel
	}
}
