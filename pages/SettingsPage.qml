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
				//% "General"
				text: qsTrId("settings_general"),
				page: "/pages/settings/GeneralSettingsPage.qml"
			},
			{
				//% "Display & Language"
				text: qsTrId("settings_display_and_language"),
				page: "/pages/settings/DisplayAndLanguageSettingsPage.qml"
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
