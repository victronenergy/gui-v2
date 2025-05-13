/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

/*
 * These settings are regularly brought up to date with the settings from gui-v1.
 * Currently up to date with gui-v1 v5.6.6.
 */

import QtQuick
import Victron.VenusOS

SwipeViewPage {
	id: root

	//% "Settings"
	navButtonText: qsTrId("nav_settings")
	navButtonIcon: "qrc:/images/settings.svg"
	url: "qrc:/qt/qml/Victron/VenusOS/pages/SettingsPage.qml"
	topLeftButton: VenusOS.StatusBar_LeftButton_ControlsInactive
	activeFocusOnTab: true
	blockInitialFocus: true

	GradientListView {
		id: settingsListView

		clip: true
		model: VisibleItemModel {
			SettingsListNavigation {
				text: CommonWords.devices
				//% "All connected devices"
				secondaryText: qsTrId("settings_all_connected_devices")
				pageSource: "/pages/settings/devicelist/DeviceListPage.qml"
				iconSource: "qrc:/images/icon_devices_32.png"
			}

			SettingsListHeader { } // blank spacer

			SettingsListNavigation {
				//% "General"
				text: qsTrId("settings_general")
				//% "Access control, Display, Firmware, Support"
				secondaryText: qsTrId("settings_access_control_display_firmware")
				pageSource: "/pages/settings/PageSettingsGeneral.qml"
				iconSource: "qrc:/images/icon_general_32.png"
			}

			SettingsListNavigation {
				//% "Connectivity"
				text: qsTrId("settings_connectivity")
				//% "Ethernet, Wi-Fi, Bluetooth, VE.Can"
				secondaryText: qsTrId("settings_ethernet_wifi_bluetooth_vecan")
				pageSource: "/pages/settings/PageSettingsConnectivity.qml"
				iconSource: "qrc:/images/icon_connectivity_32.png"
			}

			SettingsListNavigation {
				//% "VRM"
				text: qsTrId("settings_vrm")
				//% "Remote monitoring portal"
				secondaryText: qsTrId("settings_remote_monitoring_portal")
				pageSource: "/pages/settings/PageSettingsLogger.qml"
				iconSource: "qrc:/images/icon_vrm_32.png"
			}

			SettingsListHeader {
				//% "Advanced"
				text: qsTrId("settings_advanced")
			}

			SettingsListNavigation {
				//% "Integrations"
				text: qsTrId("settings_integrations")
				//% "Relays, Sensors, Tanks, PV Inverters, Modbus, MQTT…"
				secondaryText: qsTrId("settings_relays_sensors_tanks")
				pageSource: "/pages/settings/PageSettingsIntegrations.qml"
				iconSource: "qrc:/images/icon_integration_32.png"
			}

			SettingsListNavigation {
				//% "System Setup"
				text: qsTrId("settings_system_setup")
				//% "AC/DC system, ESS, DVCC, Battery..."
				secondaryText: qsTrId("settings_acdcsystem_ess_dvcc_battery")
				pageSource: "/pages/settings/PageSettingsSystem.qml"
				iconSource: "qrc:/images/icon_system_32.png"
			}

			SettingsListNavigation {
				//% "Debug & Develop"
				text: qsTrId("settings_debug_and_develop")
				//% "Profiling tools, debug statistics, app version..."
				secondaryText: qsTrId("settings_profilingtools_debugstatistics_appversion")
				pageSource: "/pages/settings/debug/PageDebug.qml"
				iconSource: "qrc:/images/icon_debug_32.png"
				showAccessLevel: VenusOS.User_AccessType_SuperUser
			}
		}
	}
}
