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

	This matters because building a page is slow enough that pages are compiled
	and incubated asynchronously instead of freezing the UI. Doing that without
	cancelling a push that has been superseded makes a page appear on top of
	wherever the user navigated to instead, some time after they left.
*/
UiTestCase {
	id: root

	// A page that is slow to build, so that a push of it is unlikely to complete
	// within a single event loop iteration. Avoid PageBatterySettings: destroying it
	// hits QTBUG-123496 (ObjectModelMonitor/QQmlDelegateModel objectRef underflow).
	readonly property string slowPageUrl: "/pages/settings/devicelist/DeviceListPage.qml"
	readonly property string otherPageUrl: "/pages/settings/PageSettingsDisplayAndAppearance.qml"

	window: Global.main

	// Event-loop turns while a page is still being built. Do not use
	// pageStack.animating: that is also true during the slide, so a
	// synchronous push would still score ticks after construction.
	property int _ticks
	property var _rebuildPageComponent

	property Timer ticker: Timer {
		interval: 16
		repeat: true
		onTriggered: {
			if (Global.pageManager.pageStack._pendingBuild) {
				root._ticks++
			}
		}
	}

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
		Destroying the UI while an abandoned incubator is still running must not
		crash.

		An incubator cannot be aborted. Leaving while a page is being built takes
		it off _pendingBuild but the work continues. Main.rebuildUi() then drops
		guiLoader, which destroys the PageStack. If teardown only force-completes
		_pendingBuild, the abandoned incubator's finish() later dereferences the
		destroyed stack.

		URL pushes are not enough: createComponent(Asynchronous) can still be
		Loading when pop/rebuild run, so teardown only destroys the Component
		and _abandonedIncubators is never populated. Push a Ready Component
		twice so the first request reaches incubation before it is abandoned.

		Run this first so a later QTBUG-123496 on page pop cannot hide it.
		rebuildUi() tears down MainView; later tests require the UI to come back.
	*/
	function test_abandonedIncubatorDoesNotOutliveUiRebuild() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const component = root._componentForPageUrl(root.slowPageUrl)
				if (!component || component.status === Component.Error) {
					console.warn("Could not compile page component: " + (component ? component.errorString() : "null"))
					return false
				}
				if (component.status !== Component.Ready) {
					console.warn("Page component was not Ready; incubation would not be guaranteed")
					return false
				}
				// Keep the Component alive until rebuildUi() has destroyed the
				// old PageStack. pushPage() does not take ownership of a
				// caller-supplied Component, and rebuildUi() unloads the UI
				// only after this Invoke returns.
				root._rebuildPageComponent = component
				Global.pageManager.pushPage(component)
				Global.pageManager.popPage(null, PageStack.Immediate)
				Global.pageManager.pushPage(component)
				Global.main.rebuildUi()
				return true
			},
			message: "Abandon a slow page, start another, then rebuild the UI",
		})
		addStep(UiTestStep.WaitUntil, {
			timeout: 20000,
			callable: ()=> {
				if (UiConfig.splashScreenVisible) {
					Global.main.skipSplashScreen()
				}
				return !!Global.mainView
						&& Global.allPagesLoaded
						&& !Global.mainView.animating
						&& !!findItem(Global.mainView, { text: "Settings" })
			},
			message: "Wait for the UI to come back after rebuildUi()",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				root._rebuildPageComponent = null
				return _stackIsClosed()
			},
			message: "The rebuilt page stack is closed; abandoned incubators did not push",
		})
		runSteps()
	}

	/*
		Abandoned incubation must not block the next push, but must keep
		content animations paused so leftover incubators can finish on GX.

		_pendingBuild is cleared when the user leaves, so animating becomes
		false even though the incubator is still in _abandonedIncubators.
	*/
	function test_abandonedIncubationDoesNotBlockTheNextPush() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const component = root._componentForPageUrl(root.slowPageUrl)
				if (!component || component.status !== Component.Ready) {
					console.warn("Page component was not Ready; incubation would not be guaranteed")
					return false
				}
				root._rebuildPageComponent = component
				Global.pageManager.pushPage(component)
				Global.pageManager.popPage(null, PageStack.Immediate)
				const stack = Global.pageManager.pageStack
				if (stack.animating) {
					console.warn("Abandoned incubation still set animating")
					return false
				}
				if (stack._abandonedIncubators.length > 0) {
					if (!stack.incubating) {
						console.warn("Abandoned incubators were not exposed as incubating")
						return false
					}
					if (Global.mainView.allowPageAnimations) {
						console.warn("Page animations resumed while abandoned incubators are running")
						return false
					}
				}
				Global.pageManager.pushPage(root.otherPageUrl)
				return true
			},
			message: "Abandon a page being built, then open another",
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.animating && Global.pageManager.pageStack.topPageUrl === root.otherPageUrl
		} })
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				root._rebuildPageComponent = null
				return Global.pageManager.pageStack.depth === 1
						&& Global.pageManager.pageStack.topPageUrl === root.otherPageUrl
			},
			message: "The second page opened; abandoned incubation did not block it",
		})
		runSteps()
	}

	/*
		The UI must keep running while a page is being built.

		If a page is built in one go on the UI thread, the whole application
		stops until it is finished: no timer fires, no animation advances and
		no press is handled. Count ticks only while _pendingBuild is set: the
		step runner yields between Invoke/WaitUntil, so ticks after the page
		has opened do not prove the event loop ran during construction.
	*/
	function test_uiKeepsRunningWhileAPageIsOpened() {
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				root._ticks = 0
				root.ticker.start()
				Global.pageManager.pushPage(root.slowPageUrl)
				return true
			},
			message: "Open %1".arg(root.slowPageUrl),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.animating && Global.pageManager.pageStack.topPageUrl === root.slowPageUrl
		} })
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				root.ticker.stop()
				console.warn("Event loop turns while the page was being built: " + root._ticks)
				return root._ticks > 0
			},
			message: "The UI kept running while the page was being built",
		})
		runSteps()
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
		Swiping to another main page while a page is being opened must not leave that
		page behind either.

		While the page stack is closed the user can leave without touching the stack
		at all, just by swiping between the main pages, so the stack cannot rely on
		being told.
	*/
	function test_pushSupersededBySwipingAwayDoesNotOpen() {
		const startIndex = Global.mainView.swipeView.currentIndex
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				Global.pageManager.pushPage(root.slowPageUrl)
				Global.mainView.swipeView.setCurrentIndex(startIndex === 0 ? 1 : startIndex - 1)
				return true
			},
			message: "Open %1 and immediately swipe to another main page".arg(root.slowPageUrl),
		})
		addStep(UiTestStep.Wait, { timeout: 3000 })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _stackIsClosed() },
			message: "The page stack is still closed",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.mainView.swipeView.setCurrentIndex(startIndex); return true },
			message: "Swipe back",
		})
		runSteps()
	}

	/*
		Leaving while a page is being opened must not make the stack ignore what the
		user does next.

		Abandoning the build has to happen when the user leaves, not when the build
		eventually finishes. Otherwise the stack counts as busy for the rest of the
		build and silently drops the next thing the user asks for on the page they
		moved to.
	*/
	function test_leavingDuringAnOpenDoesNotBlockTheNextOne() {
		const startIndex = Global.mainView.swipeView.currentIndex
		// Separate steps, because these are separate things the user does: leaving and
		// then pressing something on the page they moved to.
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.pageManager.pushPage(root.slowPageUrl); return true },
			message: "Open %1".arg(root.slowPageUrl),
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.mainView.swipeView.setCurrentIndex(startIndex === 0 ? 1 : startIndex - 1); return true },
			message: "Swipe to another main page while it is still being built",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.pageManager.pushPage(root.otherPageUrl); return true },
			message: "Open %1 from the page moved to".arg(root.otherPageUrl),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			return !Global.mainView.animating && Global.pageManager.pageStack.topPageUrl === root.otherPageUrl
		} })
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				return Global.pageManager.pageStack.depth === 1
						&& Global.pageManager.pageStack.topPageUrl === root.otherPageUrl
			},
			message: "The second page opened, and the abandoned one did not",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.pageManager.popPage(null, PageStack.Immediate); return true },
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> { return _stackIsClosed() } })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.mainView.swipeView.setCurrentIndex(startIndex); return true },
			message: "Swipe back",
		})
		runSteps()
	}

	/*
		A page opened from the ready callback of another page must open too.

		MainView.goToConnectivityPage() is the one caller that needs the page it just
		asked for: it opens the connectivity page and then tells that page to open one
		of its own sub-pages. That second request is made from inside the completion of
		the first, which is the awkward moment for a stack that only builds one page at
		a time.

		The failure mode is not "first page wins, second ignored while building".
		The first push has already finished when the callback runs. If the follow-up
		is dropped (stack still animating, or origin mismatch abandons the Wi-Fi
		build), connectivity stays on top at depth 1.
	*/
	function test_pageOpenedFromAReadyCallbackOpens() {
		const wifiUrl = "/pages/settings/PageSettingsWifi.qml"
		const connectivityUrl = "/pages/settings/PageSettingsConnectivity.qml"
		addStep(UiTestStep.Invoke, {
			callable: ()=> { Global.mainView.goToConnectivityPage("wifi"); return true },
			message: "Go to the Wi-Fi page via the connectivity page",
		})
		addStep(UiTestStep.WaitUntil, {
			timeout: 8000,
			callable: ()=> { return !Global.mainView.animating },
			message: "Wait until both pushes have settled",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const stack = Global.pageManager.pageStack
				if (stack.topPageUrl === wifiUrl && stack.depth === 2) {
					return true
				}
				console.warn("Wanted Wi-Fi on top of connectivity (depth 2); got depth="
						+ stack.depth + " topPageUrl=" + stack.topPageUrl
						+ (stack.topPageUrl === connectivityUrl
							? " (connectivity opened, Wi-Fi follow-up did not)"
							: ""))
				return false
			},
			message: "Wi-Fi is on top of connectivity; the readyCallback follow-up was not dropped",
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
		addStep(UiTestStep.WaitUntil, {
			timeout: 8000,
			callable: ()=> {
				const stack = Global.pageManager.pageStack
				return !Global.mainView.animating && stack.opened && !!stack.currentPage
			},
			message: "Wait until the stack has settled after the two pushes",
		})
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				const stack = Global.pageManager.pageStack
				const top = stack.topPageUrl
				const depth = stack.depth
				// A push while another is still building is ignored, so the slow
				// page is alone. If the first finished in the same turn, the
				// second may also open and sit on top.
				if (depth === 1 && top === root.slowPageUrl) {
					return true
				}
				if (depth === 2 && top === root.otherPageUrl) {
					return true
				}
				console.warn("Wanted the slow page at depth 1, or both with the second on top; got depth="
						+ depth + " topPageUrl=" + top)
				return false
			},
			message: "The stack has the first page, or both with the second on top",
		})
		runSteps()
	}

	function _componentForPageUrl(url) {
		const qrcUrl = url.indexOf("qrc:") === 0 ? url : "qrc:/qt/qml/Victron/VenusOS" + url
		return Qt.createComponent(qrcUrl)
	}

	/*
		A Component-valued page (option lists, device pages) must be incubated, not
		pushed through StackView's synchronous incubator.
	*/
	function test_componentPushOpensThePage() {
		const component = _componentForPageUrl(root.otherPageUrl)
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				if (!component || component.status === Component.Error) {
					console.warn("Could not compile page component: " + (component ? component.errorString() : "null"))
					return false
				}
				Global.pageManager.pushPage(component)
				return true
			},
			message: "Open %1 as a Component".arg(root.otherPageUrl),
		})
		addStep(UiTestStep.WaitUntil, { callable: ()=> {
			const stack = Global.pageManager.pageStack
			return !Global.mainView.animating && stack.opened && !!stack.currentPage
		} })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return Global.pageManager.pageStack.depth === 1 },
			message: "The opened component page is the only page on the stack",
		})
		runSteps()
	}

	/*
		Leaving while a Component-valued page is being incubated must not leave
		that page behind.
	*/
	function test_componentPushSupersededByLeavingDoesNotOpen() {
		const component = _componentForPageUrl(root.slowPageUrl)
		addStep(UiTestStep.Invoke, {
			callable: ()=> {
				if (!component || component.status === Component.Error) {
					console.warn("Could not compile page component: " + (component ? component.errorString() : "null"))
					return false
				}
				Global.pageManager.pushPage(component)
				Global.pageManager.popPage(null, PageStack.Immediate)
				return true
			},
			message: "Open %1 as a Component and immediately leave".arg(root.slowPageUrl),
		})
		addStep(UiTestStep.Wait, { timeout: 3000 })
		addStep(UiTestStep.Invoke, {
			callable: ()=> { return _stackIsClosed() },
			message: "The page stack is still closed",
		})
		runSteps()
	}
}
