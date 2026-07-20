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

