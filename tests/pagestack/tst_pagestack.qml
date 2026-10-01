/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import QtTest

TestCase {
	id: root
	name: "PageStackTest"
	when: windowShown

	property var _stack: null

	Window {
		id: stackWindow
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height
		visible: true
	}

	Component {
		id: stackComponent
		PageStack {}
	}

	Component {
		id: testPageComponent
		Page {
			title: "DurationTestPage"
		}
	}

	function createStack() {
		const stack = stackComponent.createObject(stackWindow)
		verify(stack)
		_stack = stack
		return stack
	}

	function init() {
		UiConfig.animationEnabled = true
		UiConfig.applicationVisible = true
		Global.allPagesLoaded = true
		_stack = null
	}

	function cleanup() {
		if (_stack) {
			_stack.destroy()
			_stack = null
		}
		Global.allPagesLoaded = false
	}

	function test_animationDurationFollowsGlobalAnimationEnabled() {
		const stack = createStack()
		verify(Global.animationEnabled)
		verify(Theme.animation_page_slide_duration > 0)
		compare(stack.animationDuration, Theme.animation_page_slide_duration)

		UiConfig.animationEnabled = false
		compare(stack.animationDuration, 0)
	}

	function test_firstPushFakeSlideDurationRemainsNonzeroWhenBusy() {
		const stack = createStack()
		verify(Global.animationEnabled, "animations must be enabled to catch a zero-duration slide")
		const expectedDuration = Theme.animation_page_slide_duration
		verify(expectedDuration > 0)
		compare(stack.animationDuration, expectedDuration)
		compare(stack.x, Theme.geometry_screen_width)

		const page = stack.pushPage(testPageComponent, {})
		verify(!!page)

		// Immediate push can set StackView.busy; the fake x-slide must still have been
		// sampled with a nonzero duration, and animationDuration must not drop to 0.
		verify(stack.busy || stack.animating, "first push should leave the stack transitioning")
		verify(stack.animationDuration > 0)
		compare(stack.animationDuration, expectedDuration)
		verify(stack.fakePushDuration > 0)
		compare(stack.fakePushDuration, expectedDuration)
		verify(stack.x !== 0)
	}
}
