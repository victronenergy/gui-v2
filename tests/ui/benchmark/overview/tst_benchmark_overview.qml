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

	function initTestCase() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !!findItem(Global.mainView, { text: "Overview" }) } })
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_wait_on_overview() {
		// Just wait while animations run; the benchmark script captures render timing externally.
		addStep(UiTestStep.Wait, { timeout: 30000 })
		runSteps()
	}
}
