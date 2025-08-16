/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	required property Page currentMainPage
	required property PageStack pageStack
	required property NavBar navBar

	property int interactivity: VenusOS.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: !Global.splashScreenVisible
			&& (currentMainPage?.fullScreenWhenIdle || Global.keyNavigationEnabled)
			&& root.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			&& BackendConnection.applicationVisible
		interval: Theme.animation_page_idleResize_timeout
		onTriggered: {
			Global.main.keyNavigationTimeout()
			if (currentMainPage?.fullScreenWhenIdle) {
				root.interactivity = VenusOS.PageManager_InteractionMode_EnterIdleMode
			}
		}
	}

	property string _hiddenStackMainPage

	function pushPage(obj, properties, operation = PageStack.PushTransition) {
		pageStack.pushPage(obj, properties, operation)
	}

	function popPage(toPage, operation = PageStack.PopTransition) {
		pageStack.popPage(toPage, operation)
	}

	function popToAbovePage(page, operation = PageStack.PopTransition) {
		if (page) {
			const stackView = page.StackView.view
			for (let i = stackView.depth - 1; i >= 0; --i) {
				if (stackView.get(i, StackView.DontLoad) === page) {
					const targetPage = i === 0 ? null : stackView.get(i - 1, StackView.DontLoad)
					if (targetPage) {
						root.popPage(targetPage)
						return
					}
				}
			}
		}
		popAllPages(operation)
	}

	function popAllPages(operation = PageStack.PopTransition) {
		pageStack.popAllPages(operation)
	}

	function ensureInteractive() {
		if (idleModeTimer.running) {
			idleModeTimer.restart()
		}
		if (interactivity === VenusOS.PageManager_InteractionMode_Idle) {
			interactivity = VenusOS.PageManager_InteractionMode_EndFullScreen
			return true
		}
		return false
	}

	function goToStartPage() {
		const config = Global.systemSettings.startPageConfiguration.startPageInfo
		const prevMainPage = navBar.getCurrentPage()

		// Load the main page and its properties.
		if (!Global.mainView || !config?.main || !navBar.setCurrentPage(config.main.page)) {
			return
		}
		const mainPage = Global.mainView.swipeView.getCurrentPage()
		for (const propertyName in config.main.properties) {
			if (mainPage.hasOwnProperty(propertyName)) {
				mainPage[propertyName] = config.main.properties[propertyName]
			}
		}

		// If the stack is already showing the correct page, there's nothing more to do.
		const configStackPages = config.stack || []
		if (configStackPages.length > 0
				&& configStackPages[configStackPages.length - 1].page === pageStack.topPageUrl) {
			return
		}

		if (configStackPages.length > 0) {
			// The config contains a stack page (i.e. a drilldown or settings sub-page like the
			// Battery List page.
			if (pageStack.depth > 0) {
				// We are currently on a stack page, and need to show the configured stack page.
				// Pop all current stack pages before pushing the configured pages onto the stack.
				popAllPages(StackView.Immediate)
			}
			for (let i = 0; i < configStackPages.length; ++i) {
				if (configStackPages[i].page) {
					pushPage(configStackPages[i].page, configStackPages[i].properties || {})
				}
			}
		} else if (pageStack.depth > 0) {
			// There are no config stack pages, but we are currently on a stack page. Hide the stack
			// instead of popping all of its pages, so that we can return instantly to this stack
			// page later.
			_hiddenStackMainPage = prevMainPage
			pageStack.hide()
		}
	}

	function goToStartPageOrNextMainPage() {
		if (pageStack.opened) {
			// If a stack page is currently shown:
			// - if there is no Start Page, or this is already the Start Page, then hide the stack
			//   to reveal the main page below.
			// - otherwise, go to the start page.
			const config = Global.systemSettings.startPageConfiguration.startPageInfo
			if (!config || config.stack[config.stack.length - 1]?.page === pageStack.topPageUrl) {
				_hiddenStackMainPage = navBar.getCurrentPage()
				pageStack.hide()
			} else {
				goToStartPage()
			}
		} else {
			// If a main page is currently shown, then cycle through the main pages in the nav bar.
			navBar.setCurrentIndex(Utils.modulo(navBar.currentIndex + 1, navBar.model.count))
		}
	}

	function returnToLastStackPage() {
		if (pageStack.show()) {
			// When the pageStack "opened" animation finishes, change the underlying main page to
			// be the one that was beneath the requested stack page. E.g. if it was an Overview
			// drilldown page, then show the Overview below the stack, and not the Settings page.
			_stackConn.target = root.pageStack
		}
	}

	readonly property Connections _stackConn: Connections {
		target: null
		function onAnimatingChanged() {
			if (!root.pageStack.animating) {
				target = null
				navBar.setCurrentPage(root._hiddenStackMainPage)
			}
		}
	}

	Component.onCompleted: Global.pageManager = root
}
