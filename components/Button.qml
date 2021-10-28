/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

MouseArea {
	id: root

	property alias icon: buttonIcon
	property alias text: buttonText.text
	property var color

	height: buttonText.y + buttonText.height

	CP.ColorImage {
		id: buttonIcon

		anchors.horizontalCenter: parent.horizontalCenter
		fillMode: Image.Pad
		color: root.color
		Behavior on color {
			ColorAnimation {
				duration: 100 // TODO move into Theme if this is final
			}
		}
	}

	Label {
		id: buttonText

		anchors.top: buttonIcon.bottom
		anchors.topMargin: Theme.marginSmall
		anchors.horizontalCenter: parent.horizontalCenter

		horizontalAlignment: Text.AlignHCenter
		color: buttonIcon.color
		font.pixelSize: Theme.fontSizeMedium
	}
}
