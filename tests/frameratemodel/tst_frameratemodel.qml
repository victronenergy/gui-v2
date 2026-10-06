/*
 * Copyright (C) 2026 Victron Energy B.V.
 * See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import QtTest

TestCase {
	id: root
	name: "FrameRateModelLifecycle"
	when: windowShown

	Window {
		id: testWindow
		width: 64
		height: 64
		visible: true
		title: "FrameRateModel test"
	}

	function cleanup() {
		FrameRateModel.enabled = false
		FrameRateModel.window = null
	}

	function test_startsDisabledAndInert() {
		compare(FrameRateModel.enabled, false)
		compare(FrameRateModel.window, null)

		FrameRateModel.window = testWindow
		compare(FrameRateModel.window, testWindow)
		compare(FrameRateModel.enabled, false)

		FrameRateModel.window = null
		compare(FrameRateModel.window, null)
	}

	function test_enableDisableReconnectsWindow() {
		FrameRateModel.window = testWindow
		FrameRateModel.enabled = true
		compare(FrameRateModel.enabled, true)
		compare(FrameRateModel.window, testWindow)

		FrameRateModel.enabled = false
		compare(FrameRateModel.enabled, false)
		compare(FrameRateModel.window, testWindow)

		FrameRateModel.enabled = true
		compare(FrameRateModel.enabled, true)

		FrameRateModel.enabled = false
		FrameRateModel.window = null
		compare(FrameRateModel.window, null)
	}

	function test_replaceWindowWhileEnabled() {
		FrameRateModel.enabled = true
		FrameRateModel.window = testWindow
		compare(FrameRateModel.window, testWindow)

		FrameRateModel.window = null
		compare(FrameRateModel.window, null)
		compare(FrameRateModel.enabled, true)

		FrameRateModel.enabled = false
	}
}
