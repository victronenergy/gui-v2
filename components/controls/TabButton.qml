/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.TabButton {
	id: root

	property color color: checked ? Theme.okColor : Theme.primaryFontColor
	property color backgroundColor: "transparent"

	spacing: Theme.marginSmall

	implicitWidth: buttonText.implicitWidth + 3*spacing
	implicitHeight: buttonText.implicitHeight + 3*spacing

	font.pixelSize: Theme.fontSizeMedium

	background: Rectangle {
		id: backgroundRect

		anchors.fill: parent
		color: root.backgroundColor

		Rectangle {
			id: selectedHighlightRect

			visible: root.checked
			anchors {
				horizontalCenter: parent.horizontalCenter
				bottom: parent.bottom
			}

			width: buttonText.implicitWidth + 2*root.spacing
			height: 3

			color: Theme.okColor
		}
	}

	contentItem: Label {
		id: buttonText

		anchors.centerIn: parent
		verticalAlignment: Text.AlignVCenter
		horizontalAlignment: Text.AlignHCenter

		color: root.color
		font.pixelSize: root.font.pixelSize
		text: root.text
	}
}
