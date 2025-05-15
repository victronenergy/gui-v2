/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	GradientListView {
		model: VisibleItemModel {

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
				preferredVisible: systemNameRadioButtons.currentIndex === systemNameRadioButtons.customValueIndex
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
			}

			SettingsListHeader { }

			SettingsListNavigation {
				//% "AC System"
				text: qsTrId("pagesettingssystem_ac_system")
				//% "Inputs and Monitoring"
				secondaryText: qsTrId("pagesettingssystem_inputs_and_monitoring")
				pageSource: "/pages/settings/PageSettingsAcSystem.qml"
			}

			SettingsListNavigation {
				text: systemType.value === "Hub-4" ? systemType.value : CommonWords.ess
				//% "Energy Storage System"
				secondaryText: qsTrId("pagesettingssystem_energy_storage_System")
				pageSource: "/pages/settings/PageSettingsHub4.qml"

				VeQuickItem {
					id: systemType
					uid: Global.system.serviceUid + "/SystemType"
				}
			}

			SettingsListNavigation {
				text: CommonWords.batteries
				//% "Batteries and Battery Management Systems (BMS)"
				secondaryText: qsTrId("pagesettingssystem_batteries_and_bms")
				pageSource: "/pages/settings/PageSettingsBatteries.qml"
			}

			SettingsListNavigation {
				//% "Charge Control"
				text: qsTrId("settings_system_charge_control")
				//% "Distributed Voltage and Current Control (DVCC)"
				secondaryText: qsTrId("pagesettingssystem_distributed_voltage_and_current_control")
				pageSource: "/pages/settings/PageSettingsDvcc.qml"
			}

			ListSwitch {
				dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
				height: Theme.geometry_settingsListNavigation_height
				//% "Display DC Loads"
				text: qsTrId("settings_system_has_dc_system")
			}

			ListNavigation {
				//% "System status"
				text: qsTrId("settings_system_system_status")
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSystemStatus.qml", { title: text })
			}
		}
	}
}
