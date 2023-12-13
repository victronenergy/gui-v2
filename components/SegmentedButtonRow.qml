/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int fontPixelSize: Theme.font.size.body3
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

			model: null

			delegate: AsymmetricRoundedRectangle {
				id: buttonDelegate

				width: root.width / buttonRepeater.count
				height: parent.height
				color: modelData.enabled === false && model.index !== root.currentIndex
					   ? Theme.color.background.disabled
					   : (mouseArea.pressed || model.index === root.currentIndex
						  ? Theme.color.ok
						  : Theme.color.darkOk)
				border.width: Theme.geometry.button.border.width
				border.color: modelData.enabled === false && model.index !== root.currentIndex ? color : Theme.color.ok
				radius: Theme.geometry.button.radius

				roundedSide: model.index === 0 ? Enums.AsymmetricRoundedRectangle_RoundedSide_Left
					: model.index === (buttonRepeater.count-1) ? Enums.AsymmetricRoundedRectangle_RoundedSide_Right
					: Enums.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

				Label {
					anchors.centerIn: parent
					font.pixelSize: root.fontPixelSize
					text: modelData.value
					color: modelData.enabled === false && model.index !== root.currentIndex
						   ? Theme.color.font.disabled
						   : (mouseArea.pressed || model.index === root.currentIndex
							  ? Theme.color.button.down.text
							  : Theme.color.font.primary)
				}

				MouseArea {
					id: mouseArea

					anchors.fill: parent
					enabled: modelData.enabled !== false

					onClicked: {
						root.buttonClicked(model.index)
						root.currentIndex = model.index
					}
				}
			}
		}
	}
}
