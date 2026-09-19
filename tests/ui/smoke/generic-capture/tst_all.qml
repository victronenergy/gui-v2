/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
	id: root

	window: Global.main

	function test_boat() {
		const boatButton = findClickableChild(findItem(Global.mainView, { text: "Boat" }))
		if (boatButton) {
			addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(boatButton) } })
			addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "boat" })
			runSteps()
		} else {
			goToNextTestFunction()
		}
	}

	function test_brief() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Brief" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "brief" })
		runSteps()
	}

	function test_overview() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "overview" })
		runSteps()
	}

	function test_levels() {
		const levelsButton = findClickableChild(findItem(Global.mainView, { text: "Levels" }))
		if (levelsButton) {
			addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(levelsButton) } })
			addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "levels" })
			runSteps()
		} else {
			goToNextTestFunction()
		}
	}

	function test_notifications() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Notifications" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "notifications" })
		runSteps()
	}

	function test_settings() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Settings" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(recursivePageCapture.start)
	}

	function cleanup() {
		// Pop any pages that this test function left open, so that the next one starts from the
		// same state. A test function does not always get to finish tidily: when a step fails the
		// rest of its steps are abandoned, and any pages it had pushed by then stay on the stack,
		// where the next test function would click into them and fail for reasons of its own.
		//
		// Pop without a transition, because a click is ignored while the page stack animates.
		Global.pageManager.popAllPages(PageStack.Immediate)
		if (Global.pageManager.pageStack.depth > 0) {
			// A pop is refused while the stack animates, and a page can refuse one from tryPop().
			// Say so, rather than letting the next test function fail somewhere unrelated.
			console.warn("cleanup(): the page stack still holds",
					Global.pageManager.pageStack.depth, "page(s); the next test function starts on",
					"the previous one's page.")
		}

		// No steps have been added, so call goToNextTestFunction() instead of runSteps() to
		// continue the testing.
		goToNextTestFunction()
	}

	function test_control_cards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "cards" })
		runSteps(closeControlCards)
	}

	function closeControlCards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root

		// Ignore the VeQItem debug pages - we don't really care about their contents and there are
		// so many pages that it massively increases the time for a test run.
		excludedPageUrls: ["/pages/settings/debug/PageDebugVeQItems.qml"]
	}
}

