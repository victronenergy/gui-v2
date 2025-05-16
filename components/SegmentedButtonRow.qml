/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property int fontPixelSize: Theme.font_size_body3
	property alias model: buttonRepeater.model
	property int currentIndex

	signal buttonClicked(buttonIndex: int)

	implicitWidth: parent.width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	Keys.onSpacePressed: {
		if (buttonRepeater.count > 0) {
			if (currentIndex < 0) {
				currentIndex = 0
			}
			buttonRepeater.itemAt(currentIndex).focus = true
		}
	}
	Keys.enabled: Global.keyNavigationEnabled

	// When the row is focused but none of its individual items are focused/highlighted, then
	// highlight the row as a whole.
	KeyNavigationHighlight {
		anchors.fill: buttonRow
		active: root.currentIndex < 0 && parent.activeFocus
	}

	Row {
		id: buttonRow

		height: parent.height
		width: parent.width

		Repeater {
			id: buttonRepeater

			model: null

			delegate: T.Button {
				id: mouseArea

				enabled: root.enabled && modelData.enabled !== false
				width: root.width / buttonRepeater.count
				height: parent ? parent.height : 0
				background: AsymmetricRoundedRectangle {
					id: buttonDelegate

					width: root.width / buttonRepeater.count
					height: parent ? parent.height : 0
					color: mouseArea.enabled === false && model.index !== root.currentIndex
						   ? Theme.color_background_disabled
						   : ((mouseArea.pressed || model.index === root.currentIndex)
							  ? Theme.color_ok
							  : Theme.color_darkOk)
					border.width: Theme.geometry_button_border_width
					border.color: (mouseArea.enabled === false && model.index !== root.currentIndex) ? buttonDelegate.color : Theme.color_ok
					radius: Theme.geometry_button_radius
					roundedSide: model.index === 0 ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
							: model.index === (buttonRepeater.count-1) ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right
							: VenusOS.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

					KeyNavigationHighlight {
						anchors.fill: parent
						active: mouseArea.activeFocus
					}
				}
				contentItem: Label {
					anchors.centerIn: mouseArea
					font.pixelSize: root.fontPixelSize
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					x: Theme.geometry_tabBar_horizontalMargin
					width: parent.width - 2*x
					elide: Text.ElideRight
					text: modelData.value
					color: mouseArea.enabled === false && model.index !== root.currentIndex
						   ? Theme.color_font_disabled
						   : (mouseArea.pressed || model.index === root.currentIndex
							  ? Theme.color_button_down_text
							  : Theme.color_font_primary)
				}

				focus: model.index === root.currentIndex
				KeyNavigation.right: {
					let nextIndex = model.index + 1
					while (nextIndex < buttonRepeater.count) {
						const nextItem = buttonRepeater.itemAt(nextIndex)
						if (nextItem?.enabled) {
							return nextItem
						}
						nextIndex++
					}
					return null
				}

				onClicked: {
					root.buttonClicked(model.index)
					root.currentIndex = model.index
				}
			}
		}
	}
}
