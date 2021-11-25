/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Button {
	id: root

	property color color: Theme.primaryFontColor
	property color backgroundColor: flat
			? 'transparent'
			: down ? Theme.okColor : Theme.okSecondaryColor
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius
	property bool centerIconVertically

	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0
	leftInset: 0
	rightInset: 0
	topInset: 0
	bottomInset: 0
	spacing: Theme.marginSmall

	implicitWidth: Math.max(buttonText.implicitWidth, buttonIcon.implicitWidth)
	implicitHeight: buttonIcon.status === Image.Null
			? buttonText.height
			: buttonText.y + buttonText.height
	height: 40

	icon.width: buttonIcon.implicitWidth
	icon.height: buttonIcon.implicitHeight
	icon.color: root.color

	font.pixelSize: Theme.fontSizeMedium
	flat: true

	background: Rectangle {
		id: backgroundRect

		color: root.backgroundColor
		border.width: root.flat ? 0 : 2
		border.color: Theme.okColor
		radius: 6
	}

	contentItem: Item {
		CP.ColorImage {
			id: buttonIcon

			anchors.horizontalCenter: parent.horizontalCenter
			anchors.verticalCenter: centerIconVertically ? parent.verticalCenter : undefined
			fillMode: Image.Pad

			source: root.icon.source
			width: root.icon.width
			height: root.icon.height
			color: root.icon.color
			cache: root.icon.cache

			Behavior on color {
				ColorAnimation {
					duration: 100 // TODO move into Theme if this is final
				}
			}
		}

		Label {
			id: buttonText

			x: parent.width/2 - width/2
			y: buttonIcon.status === Image.Null
			   ? parent.height/2 - height/2
			   : buttonIcon.y + buttonIcon.height + root.spacing
			verticalAlignment: Text.AlignVCenter
			horizontalAlignment: Text.AlignHCenter

			color: root.color
			font.pixelSize: root.font.pixelSize
			text: root.text
		}
	}
}
