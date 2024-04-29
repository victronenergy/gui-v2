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
		when: Qt.inputMethod.visible && !!root.focusedFlickable

		PropertyChanges {
			target: root.focusedFlickable
			height: Theme.geometry_screen_height - root.height - Theme.geometry_statusBar_height
		}
	}

	transitions: Transition {
		NumberAnimation {
			properties: "height"
			duration: Theme.animation_inputPanel_slide_duration
			easing.type: Easing.InOutQuad
		}
	}

	Connections {
		target: Global

		function onAboutToFocusTextField(textField, flickable) {
			if (!textField || !flickable) {
				console.warn("onAboutToFocusTextField(): invalid item/flickable:", textField, flickable)
				return
			}
			root.focusedItem = textField
			root.focusedFlickable = flickable
		}
	}
}
