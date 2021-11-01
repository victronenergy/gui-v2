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

	property int topSpacing: Theme.marginSmall
	property int interSpacing: Theme.marginSmall
	property int bottomSpacing: Theme.marginSmall
	property int horizontalSpacing: Theme.marginSmall

	implicitHeight: topSpacing + buttonIcon.height + (buttonIcon.height ? interSpacing : 0) + buttonText.height + bottomSpacing
	implicitWidth: Math.max(buttonText.implicitWidth, buttonIcon.implicitWidth) + 2*horizontalSpacing

	CP.ColorImage {
		id: buttonIcon

		anchors.horizontalCenter: parent.horizontalCenter
		y: buttonIcon.height ? root.topSpacing : 0

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

		anchors {
			top: buttonIcon.bottom
			topMargin: root.interSpacing
			horizontalCenter: parent.horizontalCenter
		}

		horizontalAlignment: Text.AlignHCenter
		color: buttonIcon.color
		font.pixelSize: Theme.fontSizeMedium
	}
}
