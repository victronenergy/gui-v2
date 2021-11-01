/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	Label {
		id: label
		anchors.centerIn: parent
		text: "SettingsPage placeholder"
	}

	Column {
		anchors {
			top: label.bottom
			topMargin: Theme.horizontalPageMargin
			horizontalCenter: parent.horizontalCenter
		}
		spacing: Theme.horizontalPageMargin
		Button {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Toggle Display Mode"
			//: Change between light and dark modes
			text: qsTrId("settings_toggle_display_mode")
			color: Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor
			onClicked: Theme.displayMode = (Theme.displayMode == Theme.Dark ? Theme.Light : Theme.Dark)
		}
		Button {
			anchors.horizontalCenter: parent.horizontalCenter
			//% "Toggle Language"
			//: Select a new language
			text: qsTrId("settings_toggle_language")
			color: Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor
			onClicked: Language.current = (Language.current === Language.English ? Language.French : Language.English)
		}
	}
}
