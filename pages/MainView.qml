/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!currentPage ? currentPage.backgroundColor : Theme.color_page_background
	property PageManager pageManager
	property bool cardsActive
	readonly property Page currentPage: cardsActive && cardsLoader.status === Loader.Ready ? cardsLoader.item
			: !!pageStack.currentItem ? pageStack.currentItem
			: !!swipeView ? swipeView.currentItem
			: null

	property alias navBarAnimatingOut: animateNavBarOut.running

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	property bool allowPageAnimations: BackendConnection.applicationVisible
									   && !pageStack.busy && (!swipeView || !swipeView.flicking)
									   && !Global.splashScreenVisible

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item

	readonly property bool screenIsBlanked: !!Global.screenBlanker && Global.screenBlanker.blanked

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded && !Global.needPageReload
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeViewLoader.active == false) {
			_loadUi()
		}
	}

	function loadStartPage() {
		Global.systemSettings.startPageConfiguration.loadStartPage(swipeView, pageStack.pageUrls)
	}


	function clearUi() {
		swipeViewLoader.active = false
		pageStack.clear()
		_loadedPages = 0
	}

	function _loadUi() {
		console.warn("Data sources ready, loading pages")
		swipeViewLoader.active = true
	}

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
		// Anchor this to the PageStack's left side, so that this view slides out of view when
		// the PageStack slides in (and vice-versa), giving the impression that the SwipeView
		// itself is part of the stack.
		anchors {
			top: parent.top
			bottom: parent.bottom
			right: pageStack.left
		}
		width: Theme.geometry_screen_width

		Loader {
			id: swipeViewLoader
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
				Global.allPagesLoaded = true
			}

			Component {
				id: swipeViewComponent
				SwipeView {
					id: _swipeView

					property bool ready: Global.allPagesLoaded && !moving // hide this view until all pages are loaded and we have scrolled back to the brief page

					onReadyChanged: if (ready) ready = true // remove binding
					anchors.fill: parent
					onCurrentIndexChanged: navBar.setCurrentIndex(currentIndex)
					contentChildren: swipePageModel.children
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

			onCurrentIndexChanged: if (swipeView) swipeView.setCurrentIndex(currentIndex)

			Component.onCompleted: pageManager.navBar = navBar
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
				duration: Theme.animation_navBar_initialize_fade_duration
			}
			OpacityAnimator {
				id: opacityAnimator
				target: navBar
				from: 0.0
				to: 1.0
				duration: Theme.animation_navBar_initialize_fade_duration
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
			duration: Theme.animation_page_idleResize_duration
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
			duration: Theme.animation_page_idleOpacity_duration
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
			duration: Theme.animation_page_idleOpacity_duration
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
			duration: Theme.animation_page_idleResize_duration
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
		animationEnabled: BackendConnection.applicationVisible
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

		Component.onCompleted: pageManager.statusBar = statusBar
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
