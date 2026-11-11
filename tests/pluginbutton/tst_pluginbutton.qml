/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtTest
import Victron.VenusOS
import Victron.GuiPlugins

TestCase {
	id: root

	name: "PluginButtonTest"
	when: windowShown
	// TestCase is invisible, so a child cannot take active focus. The key test needs that.
	visible: true
	width: 400
	height: 400

	Component {
		id: buttonComponent

		PluginButton {
			text: "Reset"
		}
	}

	function init() {
		Global.keyNavigationEnabled = false
	}

	function cleanup() {
		Global.keyNavigationEnabled = false
	}

	function countSignal(signalObject) {
		const counter = { count: 0 }
		signalObject.connect(function() { counter.count += 1 })
		return counter
	}

	function test_clickEmitsClicked() {
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		tryVerify(function() { return button.width > 0 && button.height > 0 })
		const clicks = countSignal(button.clicked)

		mouseClick(button)
		compare(clicks.count, 1)
	}

	function test_spaceEmitsClickedWithKeyNavigation() {
		Global.keyNavigationEnabled = true
		const button = createTemporaryObject(buttonComponent, root)
		verify(button)
		const clicks = countSignal(button.clicked)
		verify(!button.KeyNavigationHighlight.active)

		button.forceActiveFocus()
		tryCompare(button, "activeFocus", true)
		compare(button.Window.activeFocusItem, button)
		verify(button.KeyNavigationHighlight.active)

		keyClick(Qt.Key_Space)
		compare(clicks.count, 1)

		Global.keyNavigationEnabled = false
		keyClick(Qt.Key_Space)
		compare(clicks.count, 1)
	}
}
