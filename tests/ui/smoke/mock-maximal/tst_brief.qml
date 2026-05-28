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

	function initTestCase() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Brief" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_initial() {
		addStep(UiTestStep.CaptureAndCompare, { imageName: "brief" })
		runSteps()
	}

	function test_sidePanel() {
		if (Theme.screenSize === Theme.Portrait) {
			// There is no side panel in the portrait layout.
			goToNextTestFunction()
			return
		}

		// Open side panel
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return root.findObject(Global.mainView.currentPage, {}, "BriefPage_Landscape")?.state === "panelOpened" } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "sidePanel_opened" })

		// Close side panel
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_sidepanel_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return root.findObject(Global.mainView.currentPage, {}, "BriefPage_Landscape")?.state === "initialized" } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "sidePanel_closed" })

		runSteps()
	}
}
