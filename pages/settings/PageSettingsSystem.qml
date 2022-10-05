/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property bool _isGrid: acInput1.currentIndex === 1 || acInput2.currentIndex === 1
	property bool _isShore: acInput1.currentIndex === 3 || acInput2.currentIndex === 3

	property var _acInputsModel: [
		//% "Not available"
		{ display: qsTrId("settings_system_not_available"), value: 0 },
		//% "Grid"
		{ display: qsTrId("settings_system_grid"), value: 1 },
		//% "Generator"
		{ display: qsTrId("settings_system_generator"), value: 2 },
		//% "Shore power"
		{ display: qsTrId("settings_system_shore_power"), value: 3 },
	]

	SettingsListView {
		model: ObjectModel {

			SettingsListRadioButtonGroup {
				id: systemNameRadioButtons

				//% "Vehicle"
				readonly property string systemNameVehicle: qsTrId("settings_system_name_vehicle")
				//% "Boat"
				readonly property string systemNameBoat: qsTrId("settings_system_name_boat")

				readonly property int customValueIndex: model.length - 1

				//% "System name"
				text: qsTrId("settings_system_name")
				source: "com.victronenergy.settings/Settings/SystemSetup/SystemName"
				writeAccessLevel: VenusOS.User_AccessType_User

				model: [
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

			SettingsListTextField {
				//% "User-defined name"
				text: qsTrId("settings_system_user_defined_name")
				//% "Enter name"
				placeholderText: qsTrId("settings_system_enter_user_defined_name")
				writeAccessLevel: VenusOS.User_AccessType_User
				visible: systemNameRadioButtons.currentIndex === systemNameRadioButtons.customValueIndex
				source: "com.victronenergy.settings/Settings/SystemSetup/SystemName"
			}

			SettingsListRadioButtonGroup {
				id: acInput1

				//% "AC input 1"
				text: qsTrId("settings_system_ac_input_1")
				source: "com.victronenergy.settings/Settings/SystemSetup/AcInput1"
				model: root._acInputsModel
			}

			SettingsListRadioButtonGroup {
				id: acInput2

				//% "AC input 2"
				text: qsTrId("settings_system_ac_input_2")
				source: "com.victronenergy.settings/Settings/SystemSetup/AcInput2"
				model: root._acInputsModel
			}

			SettingsListRadioButtonGroup {
				text: root._isGrid
					  //% "Monitor for grid failure"
					? qsTrId("settings_system_monitor_for_grid_failure")
					  //% "Monitor for shore disconnect"
					: qsTrId("settings_system_monitor_for_shore_disconnect")
				visible: root._isGrid || root._isShore
				source: "com.victronenergy.settings/Settings/Alarm/System/GridLost"
				model: [
					//% "Disabled"
					{ display: qsTrId("settings_system_disabled"), value: 0 },
					//% "Enabled"
					{ display: qsTrId("settings_system_enabled"), value: 1 },
				]
			}

			SettingsListRadioButtonGroup {
				id: batteryMonitorRadioButtons

				//% "Battery monitor"
				text: qsTrId("settings_system_battery_monitor")
				source: "com.victronenergy.settings/Settings/SystemSetup/BatteryService"
				//% "Unavailable monitor, set another"
				defaultSecondaryText: qsTrId("settings_system_unavailable_monitor")

				DataPoint {
					id: availableBatteryServices

					source: "com.victronenergy.system/AvailableBatteryServices"
					onValueChanged: {
						if (value === undefined) {
							return
						}
						const modelArray = Utils.jsonSettingsToModel(value)
						if (modelArray) {
							batteryMonitorRadioButtons.model = modelArray
						} else {
							console.warn("Unable to parse data from", source)
						}
					}
				}
			}

			SettingsListTextItem {
				//% "Auto-selected"
				text: qsTrId("settings_system_auto_selected")
				source: "com.victronenergy.system/AutoSelectedBatteryService"
				visible: batteryMonitorRadioButtons.model !== undefined
					&& batteryMonitorRadioButtons.currentIndex >= 0
					&& batteryMonitorRadioButtons.model[batteryMonitorRadioButtons.currentIndex].value === "default"
			}

			SettingsListSwitch {
				//% "Has DC system"
				text: qsTrId("settings_system_has_dc_system")
				source: "com.victronenergy.settings/Settings/SystemSetup/HasDcSystem"
			}

			SettingsListNavigationItem {
				//% "Battery Measurements"
				text: qsTrId("settings_system_battery_measurements")
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteries.qml")
			}

			SettingsListNavigationItem {
				//% "System Status"
				text: qsTrId("settings_system_system_status")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSystemStatus.qml")
			}
		}
	}
}
