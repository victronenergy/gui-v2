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

	Button {
		id: displayModeButton

		anchors {
			topMargin: Theme.horizontalPageMargin
			top: label.bottom
			horizontalCenter: parent.horizontalCenter
		}

		text: "Toggle Display Mode"
		color: Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor
		onClicked: Theme.displayMode = (Theme.displayMode == Theme.Dark ? Theme.Light : Theme.Dark)
	}
}
