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
		anchors {
			topMargin: Theme.horizontalPageMargin
			top: label.bottom
			horizontalCenter: parent.horizontalCenter
		}

		width: implicitWidth; height: implicitHeight
		text: "Toggle Scale"
		color: Theme.scaleFactor == 1.0 ? Theme.primaryFontColor : Theme.okColor
		onClicked: Theme.scaleFactor = (Theme.scaleFactor == 1.0 ? 1.25 : 1.0)
	}
}
