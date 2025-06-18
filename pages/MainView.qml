/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	readonly property color backgroundColor: !!currentPage ? currentPage.backgroundColor : Theme.color_page_background
	property PageManager pageManager
	property bool cardsActive
	readonly property Page currentPage: cardsActive && cardsLoader.status === Loader.Ready ? cardsLoader.item
			: !!pageStack.currentItem ? pageStack.currentItem
			: !!swipeView ? swipeView.currentItem
			: null

	property alias navBarAnimatingOut: animateNavBarOut.running

	property bool mainViewVisible: BackendConnection.applicationVisible && !Global.splashScreenVisible
	onMainViewVisibleChanged: if (mainViewVisible) console.info("MainView: UI loaded and visible")

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	property bool allowPageAnimations: Global.animationEnabled
									   && mainViewVisible
									   && !pageStack.busy && (!swipeView || !swipeView.flicking)

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item

	readonly property bool screenIsBlanked: !!Global.screenBlanker && Global.screenBlanker.blanked

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded && !Global.needPageReload
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeViewLoader.active == false) {
			console.info("MainView: data sources ready, loading swipe view pages")
			swipeViewLoader.active = true
		}
	}

	readonly property Item _focusTarget: cardsLoader.enabled ? cardsLoader
			: pageStack.depth > 0 && !pageStack.animating ? pageStack
			: swipeViewAndNavBarContainer

	function loadStartPage() {
		Global.systemSettings.startPageConfiguration.loadStartPage(swipeView, pageStack.pageUrls)
	}

	function clearUi() {
		swipeViewLoader.active = false
		pageStack.clear()
		_loadedPages = 0
	}

	Keys.onEscapePressed: (event) => {
		if (Global.notificationLayer.deleteLastNotification()) {
			return
		} else if (cardsActive) {
			cardsActive = false
			return
		} else if (pageStack.depth > 0) {
			pageManager.popPage()
			return
		}
		event.accepted = false
	}
	Keys.onLeftPressed: (event) => {
		if (pageStack.activeFocus && pageStack.depth > 0) {
			pageManager.popPage()
			return
		}
		event.accepted = false
	}
	Keys.enabled: Global.keyNavigationEnabled

	// Revert to the start page when the application has been inactive for the period of time
	// specified by the startPageTimeout.
	Timer {
		running: !!Global.systemSettings
				 && Global.systemSettings.startPageConfiguration.hasStartPage
				 && Global.systemSettings.startPageConfiguration.startPageTimeout > 0
				 && !Global.applicationActive
		interval: Global.systemSettings.startPageConfiguration.startPageTimeout * 1000
		onTriggered: root.loadStartPage()
	}

	// Auto-select the start page when the application becomes inactive, if configured to do so.
	Connections {
		target: Global
		enabled: !!Global.systemSettings && Global.systemSettings.startPageConfiguration.autoSelect
		function onApplicationActiveChanged() {
			if (!Global.applicationActive) {
				const mainPageName = root.pageManager.navBar.getCurrentPage()
				const mainPage = swipeView.getCurrentPage()
				Global.systemSettings.startPageConfiguration.autoSelectStartPage(mainPageName, mainPage, pageStack.pageUrls)
			}
		}
	}

	FocusScope {
		id: swipeViewAndNavBarContainer

		// Anchor this to the PageStack's left side, so that this view slides out of view when
		// the PageStack slides in (and vice-versa), giving the impression that the SwipeView
		// itself is part of the stack.
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: pageStack.left
		}
		width: Theme.geometry_screen_width
		focus: root._focusTarget === swipeViewAndNavBarContainer

		KeyNavigation.up: statusBar

		Loader {
			id: swipeViewLoader

			property bool blockItemFocus
			property bool refreshBlockItemFocus: Global.keyNavigationEnabled

			anchors {
				top: parent.top
				topMargin: statusBar.height
				bottom: navBar.top
				left: parent.left
				right: parent.right
			}
			active: false
			asynchronous: true
			sourceComponent: swipeViewComponent
			visible: swipeView && swipeView.ready && pageStack.swipeViewVisible
					 && !(root.cardsActive && !cardsLoader.animationRunning)
			onLoaded: {
				// If there is an active alarm, the notifications page will be shown; otherwise, show the
				// application start page, if set.
				if (Global.notifications?.alarms.hasActive ?? false) {
					Global.notificationLayer.popAndGoToNotifications()
				} else {
					root.loadStartPage()
				}
				// Notify that the UI is ready to be displayed.
				console.info("MainView: swipe view pages loaded!")
				Global.allPagesLoaded = true
			}

			// When focused during key navigation, show a full-page focus blocker if the current
			// page has blockInitialFocus=true.
			onActiveFocusChanged: {
				if (Global.keyNavigationEnabled) {
					if (activeFocus && refreshBlockItemFocus) {
						blockItemFocus = item?.currentItem?.blockInitialFocus
						refreshBlockItemFocus = false
					} else if (!activeFocus && (statusBar.activeFocus || navBar.activeFocus)) {
						// Re-refresh the focus blocker state if navigating back from status or nav bar.
						refreshBlockItemFocus = true
					}
				}
			}

			// Space key disables the focus blocker, so that user can focus individual items on the
			// page; Escape key re-enables the blocker. Ignore the event if no change is necessary.
			Keys.onSpacePressed: (event) => {
				event.accepted = blockItemFocus
				blockItemFocus = false
			}
			Keys.onEscapePressed: (event) => {
				const shouldBlockFocus = item?.currentItem?.blockInitialFocus
				event.accepted = shouldBlockFocus && !blockItemFocus
				blockItemFocus = shouldBlockFocus
			}
			Keys.enabled: Global.keyNavigationEnabled
			KeyNavigation.down: navBar
			KeyNavigationHighlight.active: swipeViewLoader.blockItemFocus
										   && swipeViewLoader.activeFocus
										   && root.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			KeyNavigationHighlight.leftMargin: Theme.geometry_page_content_horizontalMargin
			KeyNavigationHighlight.rightMargin: Theme.geometry_page_content_horizontalMargin

			Component {
				id: swipeViewComponent
				SwipeView {
					id: _swipeView

					property bool ready: Global.allPagesLoaded && !moving // hide this view until all pages are loaded and we have scrolled back to the brief page
					onReadyChanged: if (ready) ready = true // remove binding

					anchors.fill: parent
					focus: !swipeViewLoader.blockItemFocus
					contentChildren: swipePageModel.children
					onCurrentIndexChanged: navBar.setCurrentIndex(currentIndex)
				}
			}

			SwipePageModel {
				id: swipePageModel
				view: swipeView
			}
		}

		NavBar {
			id: navBar

			y: root.height + 4  // nudge below the visible area for wasm
			backgroundColor: root.backgroundColor
			opacity: 0
			model: swipeView ? swipeView.contentModel : null

			// Give the NavBar the initial focus within MainView, when key navigation is enabled.
			focus: Global.keyNavigationEnabled

			onCurrentIndexChanged: {
				if (swipeView) {
					swipeView.setCurrentIndex(currentIndex)
					if (Global.keyNavigationEnabled) {
						focus = true // Move focus back to navbar if the SwipeView page changes.
					}
				}
			}

			onActiveFocusChanged: {
				// If the key navigation moves upwards from the NavBar to the SwipeView, suggest to
				// the SwipeView that it should focus the bottom-most item in the page.
				if (activeFocus && root.swipeView) {
					root.swipeView.focusEdgeHint = Qt.BottomEdge
				}
			}

			Component.onCompleted: pageManager.navBar = navBar

			// Only move focus to SwipeView if its current page allows key navigation.
			KeyNavigation.up: root.swipeView?.currentItem?.activeFocusOnTab ? swipeViewLoader : statusBar
		}
	}

	// This stack is used to view Overview drilldown pages and Settings sub-pages. When
	// Global.pageManager.pushPage() is called, pages are pushed onto this stack.
	PageStack {
		id: pageStack

		anchors {
			top: statusBar.bottom
			bottom: parent.bottom
		}
		x: width
		width: Theme.geometry_screen_width
		focus: root._focusTarget === pageStack

		KeyNavigation.up: statusBar
	}

	CardViewLoader {
		id: cardsLoader

		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}
		statusBarItem: statusBar
		navBarItem: navBar
		swipeViewItem : swipeView
		backgroundColor: root.backgroundColor
		viewActive: root.cardsActive
		animationEnabled: root.allowPageAnimations
		focus: root._focusTarget === cardsLoader
		KeyNavigation.up: statusBar

		Component {
			id: controlCardsComponent
			ControlCardsPage {}
		}

		Component {
			id: auxCardsComponent
			AuxCardsPage {}
		}
	}

	SequentialAnimation {
		running: !Global.splashScreenVisible

		// Force the final animation values in case the Animators are
		// not run (skipping the splash screen causes the animations to
		// start before the parent is visible).
		onStopped: {
			navBar.y = yAnimator.to
			navBar.opacity = opacityAnimator.to
		}

		PauseAnimation {
			duration: Theme.animation_navBar_initialize_delayedStart_duration
		}
		ParallelAnimation {
			YAnimator {
				id: yAnimator
				target: navBar
				from: root.height - navBar.height + Theme.geometry_navigationBar_initialize_margin
				to: root.height - navBar.height
				duration: Global.animationEnabled ? Theme.animation_navBar_initialize_fade_duration : 1
			}
			OpacityAnimator {
				id: opacityAnimator
				target: navBar
				from: 0.0
				to: 1.0
				duration: Global.animationEnabled ? Theme.animation_navBar_initialize_fade_duration : 1
			}
		}
	}

	SequentialAnimation {
		id: animateNavBarIn

		running: !!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
										  || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode)

		YAnimator {
			target: navBar
			from: root.height
			to: root.height - navBar.height
			duration: Global.animationEnabled ? Theme.animation_page_idleResize_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: {
				if (!!Global.pageManager) {
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_ExitIdleMode
				}
			}
		}
		OpacityAnimator {
			target: navBar
			from: 0.0
			to: 1.0
			duration: Global.animationEnabled ? Theme.animation_page_idleOpacity_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: {
				if (!!Global.pageManager) {
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Interactive
				}
			}
		}
	}

	SequentialAnimation {
		id: animateNavBarOut

		running: !!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EnterIdleMode
										  || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen)

		OpacityAnimator {
			target: navBar
			from: 1.0
			to: 0.0
			duration: Global.animationEnabled ? Theme.animation_page_idleOpacity_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: {
				if (!!Global.pageManager) {
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_BeginFullScreen
				}
			}
		}
		YAnimator {
			target: navBar
			from: root.height - navBar.height
			to: root.height
			duration: Global.animationEnabled ? Theme.animation_page_idleResize_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: {
				if (!!Global.pageManager) {
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Idle
				}
			}
		}
	}

	StatusBar {
		id: statusBar

		pageStack: pageStack
		title: !!root.currentPage ? root.currentPage.title || "" : ""
		leftButton: {
			const customButton = !!root.currentPage ? root.currentPage.topLeftButton : VenusOS.StatusBar_LeftButton_None
			if (customButton === VenusOS.StatusBar_LeftButton_None && pageStack.depth > 0) {
				return VenusOS.StatusBar_LeftButton_Back
			}
			return customButton
		}
		rightButton: !!root.currentPage ? root.currentPage.topRightButton : VenusOS.StatusBar_RightButton_None
		animationEnabled: Global.animationEnabled
		backgroundColor: root.backgroundColor

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				cardsLoader.sourceComponent = controlCardsComponent
				root.cardsActive = true
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				root.cardsActive = false
				break;
			case VenusOS.StatusBar_LeftButton_Back:
				pageManager.popPage()
				break
			default:
				break
			}
		}

		onAuxButtonClicked: {
			if (root.cardsActive) {
				root.cardsActive = false
			} else {
				cardsLoader.sourceComponent = auxCardsComponent
				root.cardsActive = true
			}
		}

		onPopToPage: function(toPage) {
			pageManager.popPage(toPage)
		}

		onActiveFocusChanged: {
			// If the key navigation moves downwards from the StatusBar to the SwipeView, suggest to
			// the SwipeView that it should focus the top-most item in the page.
			if (activeFocus) {
				root.swipeView.focusEdgeHint = Qt.TopEdge
			}
		}

		Component.onCompleted: pageManager.statusBar = statusBar
		KeyNavigation.down: cardsLoader.enabled ? cardsLoader
				: pageStack.depth > 0 ? pageStack
				: swipeViewAndNavBarContainer
	}

	GlobalKeyNavigationHighlight {
		id: globalKeyNavigationHighlight
	}

	Loader {
		active: Global.displayCpuUsage
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		sourceComponent: CpuMonitor {
			color: root.backgroundColor
		}
	}
}
