/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

FocusScope {
	id: root

	readonly property alias pageManager: pageManager
	readonly property alias navBar: navBar
	readonly property alias statusBar: statusBar

	readonly property color backgroundColor: !!currentPage ? currentPage.backgroundColor : Theme.color_page_background
	readonly property bool cardsActive: cardsLoader.viewActive
	readonly property Page currentPage: cardsActive && cardsLoader.status === Loader.Ready ? cardsLoader.item
			: pageStack.currentPage || swipeView?.currentItem
	readonly property alias cardsLoader: cardsLoader

	property alias navBarAnimatingOut: animateNavBarOut.running

	property bool mainViewVisible: BackendConnection.applicationVisible && !Global.splashScreenVisible
	onMainViewVisibleChanged: if (mainViewVisible) console.info("MainView: UI loaded and visible")

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	property bool allowPageAnimations: Global.animationEnabled
									   && mainViewVisible
									   && !pageStack.animating && (!swipeView || !swipeView.flicking)

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item

	property int _loadedPages: 0

	readonly property bool _readyToInit: Global.dataManagerLoaded && !Global.needPageReload
			&& swipeViewLoader.readyToLoad
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeViewLoader.active == false) {
			console.info("MainView: data sources ready, loading swipe view pages")
			swipeViewLoader.active = true
		}
	}

	function goToNotificationsPage() {
		pageManager.popAllPages()
		cardsLoader.hide()
		navBar.setCurrentPage("NotificationsPage.qml")
	}

	function clearUi() {
		swipeViewLoader.active = false
		pageStack.popAllPages(StackView.Immediate)
		_loadedPages = 0
	}

	Keys.onPressed: (event) => {
		if (!Global.keyNavigationEnabled) {
			event.accepted = false
			return
		}
		switch (event.key) {
		case Qt.Key_Escape:
			// Escape = close current Toast notification, or close Control/Switch pane.
			if (ToastModel.count) {
				ToastModel.removeFirst()
			} else {
				if (cardsActive) {
					cardsLoader.hide()
				} else {
					pageManager.goToStartPageOrNextMainPage()
				}
			}
			event.accepted = true
			return
		case Qt.Key_Return:
			if (cardsActive) {
				cardsLoader.hide()
			}
			pageManager.returnToLastStackPage()
			event.accepted = true
			return
		case Qt.Key_Back:
		case Qt.Key_Left:
			// Backspace or Left arrow = go to previous page.
			if (pageStack.opened) {
				pageManager.popPage()
				event.accepted = true
				return
			}
			break
		}
		event.accepted = false
	}
	Keys.enabled: Global.keyNavigationEnabled

	PageManager {
		id: pageManager
		currentMainPage: root.currentPage
		pageStack: pageStack
		navBar: navBar
	}

	// Revert to the start page when the application has been inactive for the period of time
	// specified by the startPageTimeout.  Note that the timer should be running
	// even if !Global.timersEnabled as the screen blank duration might be very short.
	Timer {
		running: !!Global.systemSettings
				 && Global.systemSettings.startPageConfiguration.hasStartPage
				 && Global.systemSettings.startPageConfiguration.startPageTimeout > 0
				 && !Global.applicationActive
		interval: Global.systemSettings.startPageConfiguration.startPageTimeout * 1000
		onTriggered: pageManager.goToStartPage()
	}

	// Auto-select the start page when the application becomes inactive, if configured to do so.
	Connections {
		target: Global
		enabled: !!Global.systemSettings && Global.systemSettings.startPageConfiguration.autoSelect
		function onApplicationActiveChanged() {
			if (!Global.applicationActive) {
				const mainPageName = navBar.getCurrentPage()
				const mainPage = swipeView.getCurrentPage()
				Global.systemSettings.startPageConfiguration.autoSelectStartPage(mainPageName, mainPage, pageStack.opened ? pageStack.topPageUrl : "")
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
		focus: Global.keyNavigationEnabled && enabled
		enabled: !pageStack.opened && !root.cardsActive

		KeyNavigation.up: statusBar

		Loader {
			id: swipeViewLoader

			readonly property bool readyToLoad: swipePageModel.completed
					&& Global.notifications && Global.notificationLayer // checked by onLoaded handler

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
			visible: swipeView && swipeView.ready && !pageStack.opened
					 && !(root.cardsActive && !cardsLoader.animationRunning)
			onLoaded: {
				// If there is an active alarm, the notifications page will be shown; otherwise, show the
				// application start page, if set.
				if (NotificationModel.activeAlarms > 0) {
					root.goToNotificationsPage()
				} else {
					pageManager.goToStartPage()
				}
				// Notify that the UI is ready to be displayed.
				console.info("MainView: swipe view pages loaded!")
				Global.allPagesLoaded = true
			}

			Keys.enabled: Global.keyNavigationEnabled
			KeyNavigation.down: navBar

			Component {
				id: swipeViewComponent
				SwipeView {
					id: _swipeView

					property bool ready: Global.allPagesLoaded && !moving // hide this view until all pages are loaded and we have scrolled back to the brief page
					onReadyChanged: if (ready) ready = true // remove binding

					anchors.fill: parent
					focus: true
					contentChildren: swipePageModel.children

					// Update the NavBar currentIndex when the view is swiped. Use onMovingChanged
					// instead of onCurrentIndexChanged to avoid triggering this on initialization.
					onMovingChanged: {
						if (!moving) {
							navBar.setCurrentIndex(currentIndex)
						}
					}
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
			focus: true

			onCurrentIndexChanged: {
				if (swipeView) {
					swipeView.setCurrentIndex(currentIndex)
				}
			}

			onActiveFocusChanged: {
				// If the key navigation moves upwards from the NavBar to the SwipeView, suggest to
				// the SwipeView that it should focus the bottom-most item in the page.
				if (activeFocus && root.swipeView) {
					root.swipeView.focusEdgeHint = Qt.BottomEdge
				}
			}

			// Only move focus to SwipeView if its current page allows key navigation.
			KeyNavigation.up: (root.swipeView?.currentItem?.focusPolicy ?? 0) & Qt.TabFocus ? swipeViewLoader : statusBar
		}
	}

	// This stack is used to view Overview drilldown pages and Settings sub-pages. When
	// pageManager.pushPage() is called, pages are pushed onto this stack.
	PageStack {
		id: pageStack

		anchors {
			top: statusBar.bottom
			bottom: parent.bottom
		}

		focus: opened
		KeyNavigation.up: statusBar
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

		running: pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
				|| pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode

		YAnimator {
			target: navBar
			from: root.height
			to: root.height - navBar.height
			duration: Global.animationEnabled ? Theme.animation_page_idleResize_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: pageManager.interactivity = VenusOS.PageManager_InteractionMode_ExitIdleMode
		}
		OpacityAnimator {
			target: navBar
			from: 0.0
			to: 1.0
			duration: Global.animationEnabled ? Theme.animation_page_idleOpacity_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: pageManager.interactivity = VenusOS.PageManager_InteractionMode_Interactive
		}
	}

	SequentialAnimation {
		id: animateNavBarOut

		running: pageManager.interactivity === VenusOS.PageManager_InteractionMode_EnterIdleMode
				 || pageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen

		OpacityAnimator {
			target: navBar
			from: 1.0
			to: 0.0
			duration: Global.animationEnabled ? Theme.animation_page_idleOpacity_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: pageManager.interactivity = VenusOS.PageManager_InteractionMode_BeginFullScreen
		}
		YAnimator {
			target: navBar
			from: root.height - navBar.height
			to: root.height
			duration: Global.animationEnabled ? Theme.animation_page_idleResize_duration : 1
			easing.type: Easing.InOutQuad
		}
		ScriptAction {
			script: pageManager.interactivity = VenusOS.PageManager_InteractionMode_Idle
		}
	}

	CardViewLoader {
		id: cardsLoader

		function show(viewComponent) {
			sourceComponent = viewComponent
			viewActive = true
		}

		function hide() {
			viewActive = false
		}

		anchors {
			left: parent.left
			right: parent.right
		}
		y: statusBar.y + statusBar.height
		height: swipeViewAndNavBarContainer.height - statusBar.height
		statusBarItem: statusBar
		navBarItem: navBar
		swipeViewItem : swipeView
		backgroundColor: root.backgroundColor
		animationEnabled: root.allowPageAnimations
		focus: viewActive

		// When the cards animates in/out, place the cards above the status bar z-order so that the
		// cards do not animate from beneath the status bar. Once the cards have animated in, place
		// them back below the status bar z-order so that status bar buttons (which have an
		// expanded mouse area) can be clicked in the areas where they overlap with the cards view.
		z: animationRunning ? 1 : 0

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

	StatusBar {
		id: statusBar

		pageStack: pageStack
		title: !!root.currentPage ? root.currentPage.title || "" : ""
		leftButton: {
			const customButton = !!root.currentPage ? root.currentPage.topLeftButton : VenusOS.StatusBar_LeftButton_None
			if (customButton === VenusOS.StatusBar_LeftButton_None && pageStack.opened) {
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
				cardsLoader.show(controlCardsComponent)
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				cardsLoader.hide()
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
				cardsLoader.hide()
			} else {
				cardsLoader.show(auxCardsComponent)
			}
		}

		onWifiButtonClicked: {
			Global.pageManager.pushPage("/pages/settings/PageSettingsWifi.qml",
					{"title": qsTrId("pagesettingsconnectivity_wifi")})
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

		KeyNavigation.down: cardsLoader.enabled ? cardsLoader
				: pageStack.opened ? pageStack
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
