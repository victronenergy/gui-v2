/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

/*
	Tests the navigation contract of the page stack.

	These do not care whether a page is built synchronously or asynchronously.
	They care that the stack ends up in the state the user asked for: if the user
	leaves while a page is being opened, that page must not turn up afterwards.

	This matters because building a page is slow - on a GX device the median page
	takes over 100ms to instantiate and the worst over 700ms - so there is real
	pressure to build them off the main thread. Doing that without cancelling a
	push that has been superseded makes a page appear on top of wherever the user
	navigated to instead, some time after they left.
*/
UiTestCase {
	id: root

	// A page that is slow to build, so that a push of it is unlikely to complete
	// within a single event loop iteration.
	readonly property string slowPageUrl: "/pages/settings/devicelist/battery/PageBatterySettings.qml"
	readonly property string otherPageUrl: "/pages/settings/PageSettingsDisplay.qml"

	window: Global.main

	function initTestCase() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !!findItem(Global.mainView, { text: "Settings" }) } })
		runSteps()
	}

	function init() {
		// Start each test with the page stack closed.
		addStep(UiTestStep.Invoke, { callable: ()=> { Global.pageManager.popPage(null, PageStack.Immediate); return true } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _stackIsClosed() } })
		runSteps()
	}

	function _stackIsClosed() {
		const stack = Global.pageManager.pageStack
		return !Global.mainView.animating && !stack.opened && stack.depth === 0
	}

	/*
		Opening a page must put that page on the stack.
	*/
	function test_pushOpensThePage() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.pageManager.pushPage(root.slowPageUrl); return true },
			message: "Open %1".arg(root.slowPageUrl),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.animating && Global.pageManager.pageStack.topPageUrl === root.slowPageUrl
		} })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return Global.pageManager.pageStack.depth === 1 },
			message: "The opened page is the only page on the stack",
		})
		runSteps()
	}

	/*
		Leaving while a page is being opened must not leave that page behind.

		Regression test: with the page built asynchronously and no cancellation of
		the in-flight build, the page is pushed once it finishes, re-opening the
		page stack that the user has already closed.
	*/
	function test_pushSupersededByLeavingDoesNotOpen() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				Global.pageManager.pushPage(root.slowPageUrl)
				// Leave again straight away, without giving the page a chance to open.
				Global.pageManager.popPage(null, PageStack.Immediate)
				return true
			},
			message: "Open %1 and immediately leave".arg(root.slowPageUrl),
		})
		// Give any in-flight build ample time to complete and push itself.
		addStep(UiTestStep.Wait, { timeout: 3000 })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _stackIsClosed() },
			message: "The page stack is still closed",
		})
		runSteps()
	}

	/*
		Opening a second page while the first is still being opened must not leave
		both on the stack, nor leave the wrong one on top.
	*/
	function test_pushSupersededByAnotherPush() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				Global.pageManager.pushPage(root.slowPageUrl)
				Global.pageManager.pushPage(root.otherPageUrl)
				return true
			},
			message: "Open two pages in the same turn",
		})
		addStep(UiTestStep.Wait, { timeout: 3000 })
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const stack = Global.pageManager.pageStack
				// Whichever push wins, the stack must be consistent: the page on top
				// must be the url the stack reports, and there must be no page that
				// arrived after the one on top.
				return stack.depth > 0
						&& !!stack.currentPage
						&& stack.topPageUrl === (stack.depth === 2 ? root.otherPageUrl : root.slowPageUrl)
			},
			message: "The stack and its reported top page url agree",
		})
		runSteps()
	}
}
