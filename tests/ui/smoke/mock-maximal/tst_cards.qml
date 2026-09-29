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

	function _statusBarIcon(fileName) {
		return findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/" + fileName) })
	}

	function _clickStatusBarIcon(fileName) {
		const icon = _statusBarIcon(fileName)
		if (!icon) {
			throw new Error("StatusBar icon not found: " + fileName)
		}
		return mouseClick(findClickableParent(icon))
	}

	function _typeIsShown(typeName) {
		const obj = findObject(Global.mainView, {}, typeName)
		return !!obj && obj.visible !== false
	}

	function _cardsIdleAndShown() {
		return !Global.mainView.animating && Global.mainView.cardsLoader.shown
	}

	function _cardsClosed() {
		return !Global.mainView.cardsActive && !Global.mainView.animating
	}

	function _cardsCanceled() {
		const loader = Global.mainView.cardsLoader
		return !Global.mainView.cardsActive
			&& !loader.incubating
			&& !loader.active
			&& !loader.shown
			&& !Global.mainView.animating
	}

	function test_close_while_incubating() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_controls_off_32.svg") },
			message: "Open control cards",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return Global.mainView.cardsLoader.viewActive },
			message: "Waiting for card overlay to become active",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const loader = Global.mainView.cardsLoader
				if (!loader.incubating) {
					throw new Error("expected ControlCardsPage to be incubating after show()")
				}
				if (!_statusBarIcon("icon_controls_on_32.svg")) {
					throw new Error("StatusBar should show the active controls icon while incubating")
				}
				return _clickStatusBarIcon("icon_controls_on_32.svg")
			},
			message: "Close control cards while first load is incubating",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsCanceled() },
			message: "Waiting for canceled card load to deactivate",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const swipe = Global.mainView.swipeView
				if (!swipe?.visible) {
					throw new Error("SwipeView should be visible after canceled incubation")
				}
				if (swipe.opacity !== 1) {
					throw new Error("SwipeView opacity should be restored after canceled incubation")
				}
				if (Global.mainView.navBar.opacity !== 1) {
					throw new Error("NavBar opacity should be restored after canceled incubation")
				}
				if (_typeIsShown("ControlCardsPage")) {
					throw new Error("ControlCardsPage should not remain shown after canceled incubation")
				}
				return true
			},
			message: "SwipeView/NavBar restored; card pane not shown",
		})
		runSteps()
	}

	function test_control_cards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(recursivePageCapture.start, [closeControlCards])
	}

	function closeControlCards() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_controls_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	function test_switch_during_close() {
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_controls_off_32.svg") },
			message: "Open control cards",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsIdleAndShown() && _typeIsShown("ControlCardsPage") },
			message: "Waiting for ControlCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				// mouseClick posts events, so use the StatusBar signals the
				// icons emit, in the same turn as hide(), while outAnimation
				// is running.
				Global.mainView.statusBar.cardsDeactivated()
				const loader = Global.mainView.cardsLoader
				if (loader.viewActive) {
					throw new Error("hide() should clear viewActive")
				}
				if (!loader.animationRunning) {
					throw new Error("expected out-animation after hide()")
				}
				Global.mainView.statusBar.auxCardsActivated()
				if (loader.viewActive) {
					throw new Error("show() of switch pane should be deferred until close finishes")
				}
				if (!loader.animationRunning) {
					throw new Error("out-animation should still be running after deferred show()")
				}
				return true
			},
			message: "Request switch pane while control cards are closing",
		})
		addStep(UiTestStep.WaitUntil, {
			callable: ()=> { return _cardsIdleAndShown() && _typeIsShown("AuxCardsPage") },
			message: "Waiting for deferred AuxCardsPage",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const loader = Global.mainView.cardsLoader
				const swipe = Global.mainView.swipeView
				if (loader.incubating) {
					throw new Error("AuxCardsPage should not still be incubating")
				}
				if (swipe?.visible) {
					throw new Error("SwipeView should be hidden once the switch pane is shown")
				}
				if (loader.opacity !== 1) {
					throw new Error("card overlay opacity should be fully shown")
				}
				if (!_typeIsShown("AuxCardsPage")) {
					throw new Error("final shown pane should be AuxCardsPage")
				}
				return true
			},
			message: "Switch pane shown; close animation completed",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _clickStatusBarIcon("icon_smartswitch_on_32.svg") },
			message: "Close switch pane",
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _cardsClosed() } })
		runSteps()
	}

	function test_switch_pane() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_smartswitch_off_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps(recursivePageCapture.start, [closeSwitchPane])
	}

	function closeSwitchPane() {
		addStep(UiTestStep.Invoke, { callable: ()=> { return mouseClick(findClickableParent(
				findItem(Global.mainView.statusBar, { "source": Qt.url("qrc:/images/icon_smartswitch_on_32.svg") }))) } })
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return !Global.mainView.animating } })
		runSteps()
	}

	RecursivePageCapture {
		id: recursivePageCapture
		testCase: root
	}
}
