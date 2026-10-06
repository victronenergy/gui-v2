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

	property real _animationElapsedAtCheck

	function initTestCase() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !!findItem(Global.mainView, { text: "Overview" }) } })
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableChild(findItem(Global.mainView, { text: "Overview" }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		addStep(UiTestStep.Invoke, { callable: ()=> {
			if (!Global.animationEnabled || !Global.systemSettings.animationEnabled) {
				console.warn("Overview benchmark: animations are disabled; Mock.UIAnimations opt-in was not applied")
				return false
			}
			const page = Global.mainView.currentPage
			if (!page || page.animationEnabled !== true) {
				console.warn("Overview benchmark: current page animations are not enabled")
				return false
			}
			const anim = findItem(Global.mainView, { objectName: "overviewConnectorAnimation" })
			if (Theme.screenSize !== Theme.Portrait) {
				if (!anim || !anim.running) {
					console.warn("Overview benchmark: connector FrameAnimation is not running")
					return false
				}
				root._animationElapsedAtCheck = anim.elapsedTime
			}
			return true
		} })
		addStep(UiTestStep.Wait, { timeout: 250 })
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			if (Theme.screenSize === Theme.Portrait) {
				return true
			}
			const anim = findItem(Global.mainView, { objectName: "overviewConnectorAnimation" })
			return !!(anim && anim.elapsedTime > root._animationElapsedAtCheck)
		} })
		runSteps()
	}

	function test_wait_on_overview() {
		// Just wait while animations run; the benchmark script captures render timing externally.
		addStep(UiTestStep.Wait, { timeout: 30000 })
		runSteps()
	}
}
