/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property bool _isGrid: acInput1.currentIndex === 1 || acInput2.currentIndex === 1
	property bool _isShore: acInput1.currentIndex === 3 || acInput2.currentIndex === 3

	property var _acInputsModel: [
		{ display: CommonWords.not_available, value: 0 },
		//% "Grid"
		{ display: qsTrId("settings_system_grid"), value: 1 },
		{ display: CommonWords.generator, value: 2 },
		//% "Shore power"
		{ display: qsTrId("settings_system_shore_power"), value: 3 },
	]

	GradientListView {
		model: ObjectModel {

			ListRadioButtonGroup {
				id: systemNameRadioButtons

				//% "Vehicle"
				readonly property string systemNameVehicle: qsTrId("settings_system_name_vehicle")
				//% "Boat"
				readonly property string systemNameBoat: qsTrId("settings_system_name_boat")

				readonly property int customValueIndex: optionModel.length - 1

				//% "System name"
				text: qsTrId("settings_system_name")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
				writeAccessLevel: VenusOS.User_AccessType_User

				optionModel: [
					//% "Automatic"
					{ display: qsTrId("settings_system_name_auto"), value: "" },
					{ display: "Hub-1", value: "Hub-1" },
					{ display: "Hub-2", value: "Hub-2" },
					{ display: "Hub-3", value: "Hub-3" },
					{ display: "Hub-4", value: "Hub-4" },
					{ display: "ESS", value: "ESS" },
					{ display: systemNameVehicle, value: systemNameVehicle },
					{ display: systemNameBoat, value: systemNameBoat },
					//% "User defined"
					{ display: qsTrId("settings_system_name_user_defined"), value: "custom" },
				]
				defaultIndex: customValueIndex
			}

			ListTextField {
				//% "User-defined name"
				text: qsTrId("settings_system_user_defined_name")
				//% "Enter name"
				placeholderText: qsTrId("settings_system_enter_user_defined_name")
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: systemNameRadioButtons.currentIndex === systemNameRadioButtons.customValueIndex
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
			}

			ListRadioButtonGroup {
				id: acInput1

				//% "AC input 1"
				text: qsTrId("settings_system_ac_input_1")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput1"
				optionModel: root._acInputsModel
			}

			ListRadioButtonGroup {
				id: acInput2

				//% "AC input 2"
				text: qsTrId("settings_system_ac_input_2")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/AcInput2"
				optionModel: root._acInputsModel
			}

			ListRadioButtonGroup {
				text: root._isGrid
					  //% "Monitor for grid failure"
					? qsTrId("settings_system_monitor_for_grid_failure")
					  //% "Monitor for shore disconnect"
					: qsTrId("settings_system_monitor_for_shore_disconnect")
				visible: root._isGrid || root._isShore
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/Alarm/System/GridLost"
				optionModel: [
					{ display: CommonWords.disabled, value: 0 },
					{ display: CommonWords.enabled, value: 1 },
				]
			}

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

			ListTextItem {
				//% "Auto-selected"
				text: qsTrId("settings_system_auto_selected")
				dataItem.uid: Global.system.serviceUid + "/AutoSelectedBatteryService"
				visible: batteryMonitorRadioButtons.optionModel !== undefined
					&& batteryMonitorRadioButtons.currentIndex >= 0
					&& batteryMonitorRadioButtons.optionModel[batteryMonitorRadioButtons.currentIndex].value === "default"
			}

			ListSwitch {
				//% "Has DC system"
				text: qsTrId("settings_system_has_dc_system")
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
			}

			ListNavigationItem {
				//% "Battery Measurements"
				text: qsTrId("settings_system_battery_measurements")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteries.qml", { title: text })
			}

			ListNavigationItem {
				//% "System Status"
				text: qsTrId("settings_system_system_status")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSystemStatus.qml", { title: text })
			}
		}
	}
}
