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
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: "/pages/settings/PageSettingsDisplay.qml"
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
}
