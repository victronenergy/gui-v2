/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Mock
import Victron.UiTest

/*
	Captures the RV illustration in each of its states.
*/
UiTestCase {
	id: root

	window: Global.main

	CamperPageConfig {
		id: pageConfig
	}

	function initTestCase() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "RV" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_states() {
		for (let i = 0; i < pageConfig.configCount(); ++i) {
			addStep(UiTestStep.Invoke, { callable: ()=> { return !!pageConfig.loadConfig(i) } })
			// The AC and DC measurements only update once per second.
			addStep(UiTestStep.Wait, { timeout: 2000 })
			addStep(UiTestStep.CaptureAndCompare, { imageName: "rv_state_" + i })
		}
		runSteps()
	}
}
