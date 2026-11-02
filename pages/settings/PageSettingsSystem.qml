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
				dataItem.uid: Services.settings.serviceUid + "/Settings/SystemSetup/SystemName"
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
				dataItem.uid: Services.settings.serviceUid + "/Settings/SystemSetup/SystemName"
			}

			ListNavigation {
				id: oppLoads

				topInset: Theme.geometry_listItem_itemSeparator_height
				//% "Opportunity Loads"
				text: qsTrId("pagesettingssystem_opportunity_loads")
				secondaryText: opportunityLoadsMode.value ? CommonWords.enabled : CommonWords.disabled
				preferredVisible: opportunityLoadsMode.valid
				contentItem: ListNavigationCaptionedLayout {
					primaryText: oppLoads.text
					primaryLabel.font: oppLoads.font
					secondaryText: oppLoads.secondaryText
					//% "Automate controllable devices to maximize solar self-consumption"
					caption: qsTrId("pagesettingssystem_automate_controllable_devices")
				}
				onClicked: Global.pageManager.pushPage("/pages/settings/PageControllableLoads.qml", { title: text })

				VeQuickItem {
					id: opportunityLoadsMode
					uid: BackendConnection.serviceUidForType("platform") + "/Services/OpportunityLoads/Mode"
				}
			}

			ListNavigation {
				id: acSystem

				topInset: Theme.geometry_listItem_itemSeparator_height
				//% "AC system"
				text: qsTrId("pagesettingssystem_ac_system")
				contentItem: ListNavigationCaptionedLayout {
					primaryText: acSystem.text
					primaryLabel.font: acSystem.font
					//% "Inputs and monitoring"
					caption: qsTrId("pagesettingssystem_inputs_and_monitoring")
				}
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsAcSystem.qml", { title: text })
			}

			ListNavigation {
				id: hub4

				text: systemType.value === "Hub-4" ? systemType.value : CommonWords.ess
				contentItem: ListNavigationCaptionedLayout {
					primaryText: hub4.text
					primaryLabel.font: hub4.font
					//% "Energy Storage System"
					caption: qsTrId("pagesettingssystem_energy_storage_System")
				}
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsHub4.qml", { title: text })

				VeQuickItem {
					id: systemType
					uid: Services.system.serviceUid + "/SystemType"
				}
			}

			ListNavigation {
				id: bms

				text: CommonWords.batteries
				contentItem: ListNavigationCaptionedLayout {
					primaryText: bms.text
					primaryLabel.font: bms.font
					//% "Batteries and Battery Management Systems (BMS)"
					caption: qsTrId("pagesettingssystem_batteries_and_bms")
				}
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsBatteries.qml", { title: text })
			}

			ListNavigation {
				id: dvcc

				//% "Charge control"
				text: qsTrId("settings_system_charge_control")
				contentItem: ListNavigationCaptionedLayout {
					primaryText: dvcc.text
					primaryLabel.font: dvcc.font
					//% "Distributed Voltage and Current Control (DVCC)"
					caption: qsTrId("pagesettingssystem_distributed_voltage_and_current_control")
				}
				onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsDvcc.qml", { title: text })
			}

			ListSwitch {
				dataItem.uid: Services.settings.serviceUid + "/Settings/SystemSetup/HasDcSystem"
				//% "Display DC loads"
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
