/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property alias model: buttonRepeater.model
	property int currentIndex

	signal buttonClicked(buttonIndex: int)

	width: 496
	height: 48

	C.ButtonGroup {
		buttons: root.children
	}

	Row {
		id: buttonRow

		width: parent.width

		Repeater {
			id: buttonRepeater

			delegate: Button {
				id: buttonDelegate

				property int modelIndex: model.index

				width: root.width / buttonRepeater.count
				height: root.height
				checked: model.index === root.currentIndex
				backgroundColor: (down || checked)
								 ? Theme.okColor
								 : Theme.okSecondaryColor
				font.pixelSize: Theme.fontSizeLarge
				radius: 8
				text: modelData

				// Use rectangles to cover the left/right edges to avoid showing the rounded
				// background rects for all non-edge buttons.
				Rectangle {
					x: -1   // cover border anti-aliasing
					width: parent.radius
					height: parent.height
					color: buttonDelegate.modelIndex !== 0
						   ? parent.backgroundColor
						   : 'transparent'
				}
				Rectangle {
					x: parent.width - width
					width: parent.radius
					height: parent.height
					color: buttonDelegate.modelIndex !== buttonRepeater.count-1
						   ? parent.backgroundColor
						   : 'transparent'
				}

				onClicked: root.buttonClicked(model.index)
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		border.color: Theme.okColor
		border.width: 2
		radius: 8
		color: 'transparent'
	}
}
