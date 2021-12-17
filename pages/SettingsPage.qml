/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	Label {
		id: label
		anchors.top: parent.top
		anchors.topMargin: 20
		anchors.horizontalCenter: parent.horizontalCenter
		text: "SettingsPage placeholder"
	}

	Column {
		anchors {
			top: label.bottom
			topMargin: Theme.geometry.page.grid.horizontalMargin
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Theme.geometry.page.grid.horizontalMargin

		Button {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Toggle Display Mode"
			//: Change between light and dark modes
			text: qsTrId("settings_toggle_display_mode")
			onClicked: {
				if (Theme.colorScheme == Theme.Dark) {
					Theme.load(Theme.screenSize, Theme.Light)
				} else {
					Theme.load(Theme.screenSize, Theme.Dark)
				}
			}
		}

		Button {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Toggle Size"
			//: Switch between 5 inch and 7 inch mode on Desktop
			text: qsTrId("settings_toggle_size")
			onClicked: {
				if (Theme.screenSize == Theme.FiveInch) {
					Theme.load(Theme.SevenInch, Theme.colorScheme)
				} else {
					Theme.load(Theme.FiveInch, Theme.colorScheme)
				}
			}
		}

		Button {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Toggle Language"
			//: Select a new language
			text: qsTrId("settings_toggle_language")
			onClicked: Language.current = (Language.current === Language.English ? Language.French : Language.English)
		}
	}
}
