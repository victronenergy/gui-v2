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
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Levels" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_initial() {
		addStep(UiTestStep.CaptureAndCompare, { imageName: "levels" })
		runSteps()
	}

	function test_tabs() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.currentPage, { text: "Environment" }))) } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "levels_environment" })

		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.currentPage, { text: "Tanks" }))) } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "levels_tanks" })

		runSteps()
	}

	function test_tanks_expanded_view() {
		// Click on the Fresh Water gauge group to open its expanded view.
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const tabListView = findItem(Global.mainView.currentPage, {}, "TanksTab")
				const freshWaterGroup = tabListView.itemAtIndex(1)
				return mouseClick(findClickableChild(freshWaterGroup))
			}
		})
		addStep(UiTestStep.CaptureAndCompare, { imageName: "levels_freshWater_expanded" })

		// Click anywhere inside the expanded view (a modal dialog) to close it.
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(
			Global.dialogLayer.currentDialog.contentItem, {})) } })
		addStep(UiTestStep.CaptureAndCompare, { imageName: "levels_freshWater_unexpanded" })

		runSteps()
	}
}
