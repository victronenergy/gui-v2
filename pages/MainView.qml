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
	readonly property Page currentPage: cardsActive && cardsLoader.status === Loader.Ready && cardsLoader.item ? cardsLoader.item
			: (pageStack.currentPage ?? swipeView?.currentItem ?? null)
	readonly property alias cardsLoader: cardsLoader

	readonly property bool notificationButtonsEnabled: (currentPage?.url?.endsWith("NotificationsPage.qml") ?? false)
			&& Services.notifications.silenceAlarmVisible

	property alias navBarAnimatingOut: animateNavBarOut.running

	property bool mainViewVisible: UiConfig.applicationVisible && !UiConfig.splashScreenVisible
	onMainViewVisibleChanged: if (mainViewVisible) console.info("MainView: UI loaded and visible")

	// File name of the page that was current before the latest main-page
	// change. A nav plugin that fails to load is removed from the list, and
	// this is the page to select instead. If it is empty, Brief is selected.
	property string _previousPageName
	property string _currentPageName

	function _recordCurrentPageName(page) {
		if (!page || !page.url) {
			return
		}
		const name = String(page.url)
		const slash = name.lastIndexOf("/")
		const fileName = slash >= 0 ? name.substring(slash + 1) : name
		if (fileName.length === 0) {
			return
		}
		if (_currentPageName.length > 0 && _currentPageName !== fileName) {
			_previousPageName = _currentPageName
		}
		_currentPageName = fileName
	}

	function _navHasPage(pageName) {
		if (!pageName) {
			return false
		}
		for (let i = 0; i < navBar.pages.length; ++i) {
			if (String(navBar.pages[i].url).endsWith("/" + pageName)) {
				return true
			}
		}
		return false
	}

	// The page list has finished changing. If the selected page was removed,
	// show the previous page, or Brief. Otherwise keep the start page unless
	// the user has already navigated.
	function _choosePageAfterListChange() {
		if (!Global.allPagesLoaded || !swipeView || swipeView.count !== navBar.pages.length) {
			return
		}
		if (_currentPageName.length > 0 && !_navHasPage(_currentPageName)) {
			navBar.setCurrentPage(_navHasPage(_previousPageName) ? _previousPageName : "BriefPage.qml")
		} else if (pageStack.opened || cardsLoader.viewActive || navBar.modified) {
			navBar.restoreCurrentPage()
		} else {
			pageManager.goToStartPage()
		}
		// Inserting or removing a page can move the view to another page without changing the
		// nav bar index, so show the nav bar's current page in the view, and record it.
		swipeView.setCurrentIndex(navBar.currentIndex)
		_recordCurrentPageName(navBar.pages[navBar.currentIndex])
	}

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	readonly property bool allowPageAnimations: Global.animationEnabled
									   && mainViewVisible
									   && !pageStack.animating && (!swipeView || !swipeView.flicking)
									   && !Theme.adjustingGeometry

	// True if any of the view animations are running.
	readonly property bool animating: pageStack.animating || swipeView?.flicking || swipeView?.moving
				|| navBarStartupAnim.running

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item

	property int _loadedPages: 0
	readonly property alias _pageStack: pageStack

	readonly property bool _readyToInit: !Global.needPageReload
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

	function goToConnectivityPage(networkType) {
		pageManager.popAllPages(StackView.Immediate)
		cardsLoader.hide()
		navBar.setCurrentPage("SettingsPage.qml")
		root.currentPage.goToConnectivityPage(networkType)
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

	// Auto-select the start page when the application becomes inactive, if configured to do so.
	Connections {
		target: Global
		enabled: Services.settings.startPageConfiguration.autoSelect
		function onApplicationActiveChanged() {
			if (!Global.applicationActive) {
				const mainPageName = navBar.getCurrentPage()
				const mainPage = swipeView.getCurrentPage()
				Services.settings.startPageConfiguration.autoSelectStartPage(mainPageName, mainPage, pageStack.opened ? pageStack.topPageUrl : "")
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
					&& Services.notifications && Global.notificationLayer // checked by onLoaded handler

			anchors {
				top: parent.top
				topMargin: Theme.geometry_statusBar_height // hardcoded, to avoid SwipeView jump when StatusBar sizes to internal content
				bottom: parent.bottom
				bottomMargin: Math.max(0, root.height - navBar.y)
				left: parent.left
				right: parent.right
			}
			active: false
			sourceComponent: swipeViewComponent
			visible: swipeView && swipeView.ready && !pageStack.opened
					 && !(root.cardsActive && !cardsLoader.animationRunning)
			onLoaded: {
				// The page list is inserted one row at a time. Do that before
				// selecting the start page, in case the view was created before
				// the model saw it.
				swipePageModel.setSwipeViewPages()
				// If there is an active alarm, the notifications page will be shown; otherwise, show the
				// application start page, if set.
				if (NotificationModel.activeAlarms > 0) {
					root.goToNotificationsPage()
				} else {
					pageManager.goToStartPage()
				}
				// If the page was already at the nav bar index, the index did not change, and
				// the page was not recorded.
				root._recordCurrentPageName(navBar.pages[navBar.currentIndex])
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
					onReadyChanged: if (ready) Qt.callLater(function() { ready = true }) // remove binding

					anchors.fill: parent
					animationEnabled: ready && root.allowPageAnimations
					focus: true

					// Update the NavBar currentIndex when the view is swiped. Use onUserMovingChanged
					// instead of onCurrentIndexChanged to avoid triggering this on initialization.
					onUserMovingChanged: {
						if (!userMoving) {
							navBar.setCurrentIndex(currentIndex)
							root._recordCurrentPageName(currentItem)
						}
					}

				}
			}

			SwipePageModel {
				id: swipePageModel
				view: swipeView
				onPagesApplied: root._choosePageAfterListChange()
			}

			// For portrait: show top/bottom gradients when user has scrolled the view.
			ViewGradient {
				z: 1
				visible: swipeView.currentItem?.showTopGradient ?? false
				rotation: 180
			}
			ViewGradient {
				z: 1
				visible: swipeView.currentItem?.showBottomGradient ?? false
				anchors.bottom: parent.bottom
			}
		}

		NavBar {
			id: navBar

			y: root.height + 4  // nudge below the visible area for wasm
			width: parent.width
			backgroundColor: root.backgroundColor
			opacity: 0
			pages: swipePageModel.pages
			moreButton: visiblePageCount < pages.length ? moreButtonComponent : null

			// Give the NavBar the initial focus within MainView, when key navigation is enabled.
			focus: true

			onCurrentIndexChanged: {
				if (swipeView) {
					swipeView.setCurrentIndex(currentIndex)
				}
				root._recordCurrentPageName(pages[currentIndex])
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

			Component {
				id: moreButtonComponent

				NavButton {
					id: moreButton

					width: navBar.buttonWidth
					//: Click to show more available items
					//% "More"
					text: qsTrId("navbar_more")
					icon.source: "qrc:/images/icon_more_dots.svg"
					focus: true
					onClicked: Global.dialogLayer.open(moreButtonDialogComponent)

					Rectangle {
						anchors {
							left: parent.horizontalCenter
							leftMargin: Theme.geometry_navigationBar_notifications_redDot_margin
							topMargin: Theme.geometry_navigationBar_notifications_redDot_margin
						}
						width: Theme.geometry_navigationBar_notifications_redDot_size
						height: Theme.geometry_navigationBar_notifications_redDot_size
						radius: Theme.geometry_navigationBar_notifications_redDot_size / 2
						color: Theme.color_critical
						visible: Services.notifications.unacknowledgedCount > 0
					}

					Component {
						id: moreButtonDialogComponent

						NavBarMoreDialog {
							title: moreButton.text
							pages: navBar.pages
							hiddenPageCount: navBar.pages.length - navBar.visiblePageCount + 1
							currentNavBarIndex: navBar.currentIndex
							onButtonClicked: (pageIndex) => {
								navBar.setCurrentIndex(pageIndex)
								close()
							}
						}
					}
				}
			}
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
		id: navBarStartupAnim
		running: !UiConfig.splashScreenVisible

		// Force the final animation values in case the Animators are
		// not run (skipping the splash screen causes the animations to
		// start before the parent is visible).
		onStopped: {
			navBar.y = Qt.binding(function() { return navBarInitialYAnimator.to })
			navBar.opacity = Qt.binding(function() { return navBarInitialOpacityAnimator.to })
		}

		PauseAnimation {
			duration: UiConfig.showSplashAnimation && Global.animationEnabled ? Theme.animation_navBar_initialize_delayedStart_duration : 1
		}
		ParallelAnimation {
			YAnimator {
				id: navBarInitialYAnimator
				target: navBar
				from: root.height - navBar.height + Theme.geometry_navigationBar_initialize_margin
				to: root.height - navBar.height
				duration: UiConfig.showSplashAnimation && Global.animationEnabled ? Theme.animation_navBar_initialize_fade_duration : 1
			}
			OpacityAnimator {
				id: navBarInitialOpacityAnimator
				target: navBar
				from: 0.0
				to: 1.0
				duration: UiConfig.showSplashAnimation && Global.animationEnabled ? Theme.animation_navBar_initialize_fade_duration : 1
			}
		}
	}

	SequentialAnimation {
		id: animateNavBarIn

		running: pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
				|| pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode

		onStopped: {
			navBar.y = Qt.binding(function() { return navBarAnimateInYAnimator.to })
			navBar.opacity = Qt.binding(function() { return navBarAnimateInOpacityAnimator.to })
		}

		YAnimator {
			id: navBarAnimateInYAnimator
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
			id: navBarAnimateInOpacityAnimator
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
		// Only do this in landscape; in portrait, the cards should slide beneath the status bar as
		// the cards may be vertically scrolled, and it looks odd if it fades over the status bar.
		z: animationRunning && Theme.screenSize !== Theme.Portrait ? 1 : 0

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

		width: parent.width

		opacity: 0.0
		pageStack: root._pageStack

		onControlCardsActivated: cardsLoader.show(controlCardsComponent)
		onAuxCardsActivated: cardsLoader.show(auxCardsComponent)
		onCardsDeactivated: cardsLoader.hide()
		onSidePanelToggled: root.currentPage.toggleSidePanel()

		Component.onCompleted: if (!UiConfig.showSplashAnimation || !Global.animationEnabled) { statusBar.opacity = 1.0 }

		Rectangle {
			anchors.fill: parent
			color: cardsLoader.statusBarBackgroundColor
		}

		SequentialAnimation {
			running: UiConfig.showSplashAnimation && !UiConfig.splashScreenVisible && Global.animationEnabled

			PauseAnimation {
				duration: Theme.animation_statusBar_initialize_delayedStart_duration
			}
			OpacityAnimator {
				target: statusBar
				from: 0.0
				to: 1.0
				duration: Theme.animation_statusBar_initialize_fade_duration
			}
		}

		KeyNavigation.down: cardsLoader.enabled ? cardsLoader
				: pageStack.opened ? pageStack
				: swipeViewAndNavBarContainer
		onActiveFocusChanged: {
			// If the key navigation moves downwards from the StatusBar to the SwipeView, suggest to
			// the SwipeView that it should focus the top-most item in the page.
			if (activeFocus) {
				root.swipeView.focusEdgeHint = Qt.TopEdge
			}
		}
	}

	GlobalKeyNavigationHighlight {
		id: globalKeyNavigationHighlight
	}

	Loader {
		y: -height // add the height offset to account for the 90 degree rotation
		   + statusBar.height + Theme.geometry_demoModeIndicator_topMargin
		active: demoMode.valid && demoMode.value > 0
		transformOrigin: Item.BottomLeft
		rotation: 90
		sourceComponent: DemoModeIndicator {}

		VeQuickItem {
			id: demoMode
			uid: Services.settings.serviceUid + "/Settings/Gui/DemoMode"
		}
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
