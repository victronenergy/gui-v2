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

	implicitWidth: parent.width
	implicitHeight: Theme.geometry.segmentedButtonRow.height

	C.ButtonGroup {
		buttons: root.children
	}

	Row {
		id: buttonRow

		height: parent.height
		width: parent.width

		Repeater {
			id: buttonRepeater

			delegate: AsymmetricRoundedRectangle {
				id: buttonDelegate

				width: root.width / buttonRepeater.count
				height: parent.height
				color: mouseArea.pressed || model.index === root.currentIndex
					   ? Theme.color.ok
					   : Theme.color.darkOk
				border.width: Theme.geometry.button.border.width
				border.color: Theme.color.ok
				radius: Theme.geometry.button.radius

				roundedSide: model.index === 0 ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
					: model.index === (buttonRepeater.count-1) ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right
					: VenusOS.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

				Label {
					anchors.centerIn: parent
					font.pixelSize: root.fontPixelSize
					text: modelData
					color: Theme.color.font.primary
				}

				MouseArea {
					id: mouseArea

					anchors.fill: parent

					onClicked: {
						root.buttonClicked(model.index)
						root.currentIndex = model.index
					}
				}
			}
		}
	}
}
