/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl
import Victron.VenusOS

MouseArea {
	id: root

	property alias icon: buttonIcon
	property alias text: buttonText.text
	property alias color: buttonIcon.color

	width: Math.max(buttonIcon.width*2, buttonText.width + Theme.marginSmall*2)
	height: buttonText.y + buttonText.height
	opacity: containsPress ? 0.5 : 1

	ColorImage {
		id: buttonIcon

		anchors.horizontalCenter: parent.horizontalCenter
		fillMode: Image.PreserveAspectFit
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
