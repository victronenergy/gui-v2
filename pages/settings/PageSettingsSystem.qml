/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	readonly property var _systemNameOptions: [
		//% "Automatic"
		{ display: qsTrId("settings_system_name_auto"), value: "" },
		{ display: "Hub-1", value: "Hub-1" },
		{ display: "Hub-2", value: "Hub-2" },
		{ display: "Hub-3", value: "Hub-3" },
		{ display: "Hub-4", value: "Hub-4" },
		{ display: "ESS", value: "ESS" },
		//% "Vehicle"
		{ display: qsTrId("settings_system_name_vehicle"), value: qsTrId("settings_system_name_vehicle") },
		//% "Boat"
		{ display: qsTrId("settings_system_name_boat"), value: qsTrId("settings_system_name_boat") },
		//% "User defined"
		{ display: qsTrId("settings_system_name_user_defined"), value: "custom" },
	]

	// True when the backend value does not match any non-custom option. Note: when the value is not
	// yet valid, ListRadioButtonGroup.currentIndex falls back to its defaultIndex, which is the
	// custom option, so the radio group displays "User defined" and this must be true as well.
	readonly property bool _isCustomSystemName: {
		if (!systemNameItem.valid) return true
		const v = systemNameItem.value
		for (let i = 0; i < _systemNameOptions.length - 1; ++i) {
			if (_systemNameOptions[i].value === v) return false
		}
		return true
	}

	VeQuickItem {
		id: systemNameItem
		uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
	}

	VeQuickItem {
		id: opportunityLoadsMode
		uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
	}

	GradientListView {
		model: DelegateComponentModel {

			DelegateComponent {
				ListRadioButtonGroup {
					//% "System name"
					text: qsTrId("settings_system_name")
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
					writeAccessLevel: VenusOS.User_AccessType_User
					optionModel: root._systemNameOptions
					defaultIndex: optionModel.length - 1
				}
			}

			DelegateComponent {
				preferredVisible: root._isCustomSystemName
				ListTextField {
					//% "User-defined name"
					text: qsTrId("settings_system_user_defined_name")
					//% "Enter name"
					placeholderText: qsTrId("settings_system_enter_user_defined_name")
					writeAccessLevel: VenusOS.User_AccessType_User
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/SystemName"
				}
			}

			DelegateComponent {
				preferredVisible: opportunityLoadsMode.valid
				ListNavigation {
					topInset: Theme.geometry_listItem_itemSeparator_height
					//% "Opportunity Loads"
					text: qsTrId("pagesettingssystem_opportunity_loads")
					//% "Automate controllable devices to maximize solar self-consumption"
					caption: qsTrId("pagesettingssystem_automate_controllable_devices")
					secondaryText: opportunityLoadsMode.value ? CommonWords.enabled : CommonWords.disabled
					onClicked: Global.pageManager.pushPage("/pages/settings/PageControllableLoads.qml", { title: text })
				}
			}

			DelegateComponent {
				ListNavigation {
					topInset: Theme.geometry_listItem_itemSeparator_height
					//% "AC system"
					text: qsTrId("pagesettingssystem_ac_system")
					//% "Inputs and monitoring"
					caption: qsTrId("pagesettingssystem_inputs_and_monitoring")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsAcSystem.qml", { title: text })
				}
			}

			DelegateComponent {
				ListNavigation {
					text: systemType.value === "Hub-4" ? systemType.value : CommonWords.ess
					//% "Energy Storage System"
					caption: qsTrId("pagesettingssystem_energy_storage_System")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsHub4.qml", { title: text })

					VeQuickItem {
						id: systemType
						uid: Global.system.serviceUid + "/SystemType"
					}
				}
			}

			DelegateComponent {
				ListNavigation {
					text: CommonWords.batteries
					//% "Batteries and Battery Management Systems (BMS)"
					caption: qsTrId("pagesettingssystem_batteries_and_bms")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteries.qml", { title: text })
				}
			}

			DelegateComponent {
				ListNavigation {
					//% "Charge control"
					text: qsTrId("settings_system_charge_control")
					//% "Distributed Voltage and Current Control (DVCC)"
					caption: qsTrId("pagesettingssystem_distributed_voltage_and_current_control")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsDvcc.qml", { title: text })
				}
			}

			DelegateComponent {
				ListSwitch {
					dataItem.uid: Global.systemSettings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
					//% "Display DC loads"
					text: qsTrId("settings_system_has_dc_system")
				}
			}

			DelegateComponent {
				showAccessLevel: VenusOS.User_AccessType_SuperUser
				ListNavigation {
					//% "System status"
					text: qsTrId("settings_system_system_status")
					onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsSystemStatus.qml", { title: text })
				}
			}
		}
	}
}
