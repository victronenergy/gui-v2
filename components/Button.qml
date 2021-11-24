/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Button {
	id: root

	leftPadding: 0
	rightPadding: 0
	topPadding: 0
	bottomPadding: 0
	leftInset: 0
	rightInset: 0
	topInset: 0
	bottomInset: 0
	spacing: Theme.marginSmall

	icon.width: buttonIcon.implicitWidth
	icon.height: buttonIcon.implicitHeight

	background: Item {
		implicitWidth: root.contentItem.implicitWidth
		implicitHeight: root.contentItem.implicitHeight
	}

	icon.color: down || checked
				? (Theme.displayMode == Theme.Dark ? Theme.primaryFontColor : Theme.okColor)
				: (Theme.displayMode == Theme.Dark ? Theme.secondaryFontColor : Theme.okSecondaryColor)

	contentItem: Item {
		implicitWidth: Math.max(buttonText.implicitWidth, buttonIcon.implicitWidth)
		implicitHeight: buttonText.y + buttonText.height

		CP.ColorImage {
			id: buttonIcon

			anchors.horizontalCenter: parent.horizontalCenter
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

			anchors {
				top: buttonIcon.bottom
				topMargin: root.spacing
				horizontalCenter: parent.horizontalCenter
			}

			horizontalAlignment: Text.AlignHCenter
			color: root.icon.color
			font.pixelSize: Theme.fontSizeMedium
			text: root.text
		}
	}
}
