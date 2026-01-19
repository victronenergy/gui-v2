/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.UiTest

UiTestCase {
	id: root

	window: Global.main

	function test_settings() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Settings" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(recursivePageCapture.start, ["settings"])
	}

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root

		// Ignore the VeQItem debug pages - we don't really care about their contents and there are
		// so many pages that it massively increases the time for a test run.
		excludedPageUrls: ["/pages/settings/debug/PageDebugVeQItems.qml"]
	}
}
