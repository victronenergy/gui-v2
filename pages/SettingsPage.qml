/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	SettingsListView {
		id: settingsListView

		model: [
			{
				//% "General"
				text: qsTrId("settings_general"),
				page: "/pages/settings/PageSettingsGeneral.qml"
			},
			{
				//% "Date & Time"
				text: qsTrId("settings_date_and_time"),
				page: "/pages/settings/PageTzInfo.qml"
			},
			{
				//% "Remote Console"
				text: qsTrId("settings_remote_console"),
				page: "/pages/settings/PageSettingsRemoteConsole.qml"
			},
			{
				//% "System setup"
				text: qsTrId("settings_system_setup"),
				page: "/pages/settings/PageSettingsSystem.qml"
			},
			{
				//% "DVCC"
				text: qsTrId("settings_system_dvcc"),
				page: "/pages/settings/PageSettingsDvcc.qml"
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: "/pages/settings/PageSettingsDisplay.qml"
			},
			{
				//% "VRM online portal"
				text: qsTrId("settings_vrm_online_portal"),
				page: "/pages/settings/PageSettingsLogger.qml"
			},
			{
				//% "ESS"
				text: systemType.value === "Hub-4" ? systemType.value : qsTrId("settings_ess"),
				page: "/pages/settings/PageSettingsHub4.qml"
			},
			{
				//% "Energy meters"
				text: qsTrId("settings_energy_meters"),
				page: "/pages/settings/PageSettingsCGwacsOverview.qml"
			},
			{
				//% "Ethernet"
				text: qsTrId("settings_ethernet"),
				page: "/pages/settings/PageSettingsTcpIp.qml"
			},
			{
				//% "Wi-Fi"
				text: qsTrId("settings_wifi"),
				page: accessPoint.valid
					? "/pages/settings/PageSettingsWifiWithAccessPoint.qml"
					: "/pages/settings/PageSettingsWifi.qml"
			},
			{
				//% "Tank pump"
				text: qsTrId("settings_tank_pump"),
				page: "/pages/settings/PageSettingsTankPump.qml"
			},
			{
				//% "Generator start/stop"
				text: qsTrId("settings_generator_start_stop"),
				page: "/pages/settings/PageRelayGenerator.qml"
			},
			{
				//% "Relay"
				text: qsTrId("settings_relay"),
				page: "/pages/settings/PageSettingsRelay.qml",
				visible: relay0.valid
			},
			{
				// TODO remove this temporary page that demonstrates the settings UI
				text: "Demo settings page",
				page: "/pages/settings/PageSettingsDemo.qml"
			},
		]

		delegate: SettingsListNavigationItem {
			text: modelData.text
			onClicked: {
				Global.pageManager.pushPage(modelData.page, {"title": modelData.text})
			}
		}
	}

	DataPoint {
		id: systemType
		source: "com.victronenergy.system/SystemType"
	}

	DataPoint {
		id: accessPoint
		source: "com.victronenergy.platform/Services/AccessPoint/Enabled"
	}

	DataPoint {
		id: relay0
		source: "com.victronenergy.system/Relay/0/State"
	}
}
