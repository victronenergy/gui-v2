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
				// Temporary, demonstrates the settings UI
				text: "Demo settings page",
				page: "/pages/settings/DemoSettingsPage.qml"
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
			},
			{
				//% "General"
				text: qsTrId("settings_general"),
			},
			{
				//% "Firmware"
				text: qsTrId("settings_firmware"),
			},
			{
				//% "Date & time"
				text: qsTrId("settings_date_and_time"),
			},
			{
				//% "Remote console"
				text: qsTrId("settings_remote_console"),
			},
			{
				//% "System setup"
				text: qsTrId("settings_system_setup"),
			},
			{
				//% "DVCC"
				text: qsTrId("settings_dvcc"),
			},
			{
				//% "VRM online portal"
				text: qsTrId("settings_vrm_online_portal"),
			},
		]

		delegate: SettingsListNavigationItem {
			text: modelData.text
			onClicked: {
				PageManager.pushPage(modelData.page, {"title": modelData.text})
			}
		}
	}
}
