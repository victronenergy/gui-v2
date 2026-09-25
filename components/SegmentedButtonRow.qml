/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

FocusScope {
	id: root

	property int fontPixelSize: Theme.font_buttonRow_size
	// Do not alias Repeater.model: a bound JS array is a new object each
	// re-eval, and setModel during nested PageStack incubation asserts.
	// Assign the Repeater only when the button count changes.
	property var model
	property int currentIndex
	property bool showBorderWhenDisabled: false

	onModelChanged: root._applyRepeaterModelIfCountChanged()

	function _applyRepeaterModelIfCountChanged() {
		const newCount = Array.isArray(root.model) ? root.model.length
				: (root.model?.count ?? (root.model != null ? 1 : 0))
		if (buttonRepeater.model != null && buttonRepeater.count === newCount) {
			return
		}
		buttonRepeater.model = root.model
	}

	signal buttonClicked(buttonIndex: int)

	function clickButton(index) {
		const button = buttonRepeater.itemAt(index)
		if (button) {
			button.click()
		}
	}

	implicitWidth: Theme.geometry_control_width
	implicitHeight: Theme.geometry_segmentedButtonRow_height

	// Set a default focus policy that will be used by each delegate in the row.
	focusPolicy: Qt.StrongFocus

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
	KeyNavigationHighlight.active: root.currentIndex < 0 && root.activeFocus
	KeyNavigationHighlight.fill: buttonRow

	Row {
		id: buttonRow

		height: parent.height
		width: parent.width

		Repeater {
			id: buttonRepeater

			delegate: T.Button {
				id: mouseArea

				readonly property var _item: root.model?.[model.index]
				enabled: root.enabled && _item?.enabled !== false
				width: root.width / buttonRepeater.count
				height: parent ? parent.height : 0
				focusPolicy: root.focusPolicy
				background: AsymmetricRoundedRectangle {
					id: buttonDelegate

					width: root.width / buttonRepeater.count
					height: parent ? parent.height : 0
					color: mouseArea.enabled === false && model.index !== root.currentIndex
						   ? Theme.color_background_disabled
						   : ((mouseArea.pressed || model.index === root.currentIndex)
							  ? mouseArea._item?.selectedBackgroundColor ?? Theme.color_ok
							  : Theme.color_darkOk)
					border.width: Theme.geometry_button_border_width
					border.color: (!root.showBorderWhenDisabled && mouseArea.enabled === false && model.index !== root.currentIndex) ? buttonDelegate.color : Theme.color_ok
					radius: Theme.geometry_button_radius
					roundedSide: model.index === 0 ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Left
							: model.index === (buttonRepeater.count-1) ? VenusOS.AsymmetricRoundedRectangle_RoundedSide_Right
							: VenusOS.AsymmetricRoundedRectangle_RoundedSide_NoneHorizontal

				}
				contentItem: Label {
					font.pixelSize: root.fontPixelSize
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
					x: Theme.geometry_tabBar_horizontalMargin
					width: parent.width - 2*x
					elide: Text.ElideRight
					text: mouseArea._item?.value ?? ""
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

				KeyNavigationHighlight.active: mouseArea.activeFocus

				onClicked: {
					root.buttonClicked(model.index)
					root.currentIndex = model.index
				}
			}
		}
	}
}
