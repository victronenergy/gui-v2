/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	property int fontPixelSize: Theme.font_size_body3
	property alias model: buttonRepeater.model
	property int currentIndex

	signal buttonClicked(buttonIndex: int)

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

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
				height: parent ? parent.height : 0
				color: modelData.enabled === false && model.index !== root.currentIndex
					   ? Theme.color_background_disabled
					   : ((mouseArea.pressed || model.index === root.currentIndex)
						  ? Theme.color_ok
						  : Theme.color_darkOk)
				border.width: Theme.geometry_button_border_width
				border.color: (modelData.enabled === false && model.index !== root.currentIndex) ? buttonDelegate.color : Theme.color_ok
				radius: Theme.geometry_button_radius

				roundedSide: model.index === 0 ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
					: model.index === (buttonRepeater.count-1) ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right
					: VenusOS.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

				Label {
					anchors.centerIn: parent
					font.pixelSize: root.fontPixelSize
					horizontalAlignment: Text.AlignHCenter
					x: Theme.geometry_tabBar_horizontalMargin
					width: parent.width - 2*x

					elide: Text.ElideRight
					text: modelData.value
					color: modelData.enabled === false && model.index !== root.currentIndex
						   ? Theme.color_font_disabled
						   : (mouseArea.pressed || model.index === root.currentIndex
							  ? Theme.color_button_down_text
							  : Theme.color_font_primary)
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
