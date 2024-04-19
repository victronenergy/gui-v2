/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.VirtualKeyboard as QtVirtualKeyboard
import Victron.VenusOS

// *** This file can be edited directly on the cerbo filesystem,
// *** but you will also need to edit ApplicationContent.qml
// *** so that the loader's source property is:
// *** "file:///opt/victronenergy/gui-v2/Victron/VenusOS/components/InputPanel.qml"

QtVirtualKeyboard.InputPanel {
	id: root

	property var mainViewItem
	property var focusedItem
	property var focusedFlickable
	property real toContentY
	property real toHeight

	function testCloseOnClick(item, itemMouseX, itemMouseY) {
		if (!Qt.inputMethod.visible || !item || !focusedItem) {
			return false
		}
		const mappedPoint = focusedItem.mapFromItem(item, itemMouseX, itemMouseY)
		if (!focusedItem.contains(mappedPoint)) {
			focusedItem.focus = false
			return true
		}
		return false
	}

	visible: Qt.inputMethod.visible || yAnimator.running
	y: Qt.inputMethod.visible ? Theme.geometry_screen_height - root.height : Theme.geometry_screen_height
	Behavior on y {
		YAnimator {
			id: yAnimator
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	width: Theme.geometry_screen_width

	states: State {
		name: "visible"
		when: Qt.inputMethod.visible

		PropertyChanges {
			target: root.focusedFlickable
			contentY: root.toContentY
			height: root.toHeight
		}
	}

	transitions: Transition {
		NumberAnimation {
			properties: "contentY,height"
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	Connections {
		target: Global

		function onAboutToFocusTextField(textField, toTextFieldY, flickable) {
			if (!textField || !flickable) {
				console.warn("onAboutToFocusTextField(): invalid item/flickable:", textField, flickable)
				return
			}
			const inputPanelY = mainViewItem.height - root.height
			const toWinY = textField.mapToItem(mainViewItem, 0, toTextFieldY).y
			const delta = toWinY - inputPanelY

			if (delta > 0) {
				// Scroll the flickable upwards to show the item above the vkb.
				root.toContentY = flickable.contentY + delta

				if (flickable.contentY + delta + flickable.height > flickable.contentHeight) {
					// Item is too close to bottom of flickable, so it will still be hidden after
					// scrolling upwards. Reduce the flickable height so that item can be seen.
					root.toHeight = flickable.height - inputPanelY
						+ ((!!Global.pageManager && !!Global.pageManager.navBar) ? Global.pageManager.navBar.height : 0)
				} else {
					// No flickable height changes required.
					root.toHeight = flickable.height
				}
			} else {
				// No position changes required, but PropertyChanges requires a valid target, so
				// set the dest values to the current values.
				root.toContentY = flickable.contentY
				root.toHeight = flickable.height
			}
			root.focusedItem = textField
			root.focusedFlickable = flickable
		}
	}
}
