/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int fontPixelSize: Theme.font.size.l
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

		height: parent.height
		width: parent.width

		Repeater {
			id: buttonRepeater
			height: parent.height

			// TODO: use QtQuick.Shape to draw the asymmetric rounded edge.
			delegate: Button {
				id: buttonDelegate

				property int modelIndex: model.index

				width: root.width / buttonRepeater.count
				height: parent.height
				checked: model.index === root.currentIndex
				backgroundColor: (down || checked)
								 ? Theme.color.ok
								 : Theme.color.darkOk
				font.pixelSize: root.fontPixelSize
				radius: 0
				text: modelData

				onClicked: {
					root.buttonClicked(model.index)
					root.currentIndex = model.index
				}
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		border.color: Theme.color.ok
		border.width: 2
		radius: 8
		color: 'transparent'
	}
}
