/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!currentPage ? currentPage.backgroundColor : Theme.color_page_background
	property PageManager pageManager
	property bool controlsActive
	readonly property Page currentPage: controlsActive && controlCardsLoader.status === Loader.Ready ? controlCardsLoader.item
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

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeViewLoader.active == false) {
			_loadUi()
		}
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

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	property SwipeView swipeView: swipeViewLoader.item
	Loader {
		id: swipeViewLoader
		// Anchor this to the PageStack's left side, so that this view slides out of view when the
		// PageStack slides in (and vice-versa), giving the impression that the SwipeView itself
		// is part of the stack.
		anchors {
			top: statusBar.bottom
			bottom: navBar.top
			right: pageStack.left
		}
		width: Theme.geometry_screen_width
		active: false
		asynchronous: true
		sourceComponent: swipeViewComponent

		visible: swipeView.ready && pageStack.swipeViewVisible && !(root.controlsActive && !controlsInAnimation.running && !controlsOutAnimation.running)
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
			Component.onCompleted: Global.allPagesLoaded = true
		}
	}

	SwipePageModel {
		id: swipePageModel
		view: swipeView
	}

	Loader {
		id: controlCardsLoader

		onActiveChanged: if (active) active = true // remove binding

		z: 1
		opacity: 0.0
		sourceComponent: ControlCardsPage { }
		active: root.controlsActive
		enabled: root.controlsActive || controlsOutAnimation.running

		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		SequentialAnimation {
			id: controlsInAnimation
			running: root.controlsActive

			ParallelAnimation {
				YAnimator {
					target: controlCardsLoader
					from: statusBar.height - Theme.geometry_controlCards_slide_distance
					to: statusBar.height
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: controlCardsLoader
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: swipeView
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				OpacityAnimator {
					target: navBar
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
				ColorAnimation {
					target: statusBar
					property: "color"
					from: root.backgroundColor
					to: Theme.color_page_background
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.OutSine
				}
			}
		}

		SequentialAnimation {
			id: controlsOutAnimation

			running: controlCardsLoader.active && !root.controlsActive

			ParallelAnimation {
				YAnimator {
					target: controlCardsLoader
					from: statusBar.height
					to: statusBar.height - Theme.geometry_controlCards_slide_distance
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: controlCardsLoader
					from: 1.0
					to: 0.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: swipeView
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				OpacityAnimator {
					target: navBar
					from: 0.0
					to: 1.0
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
				ColorAnimation {
					target: statusBar
					property: "color"
					from: Theme.color_page_background
					to: root.backgroundColor
					duration: Theme.animation_controlCards_slide_duration
					easing.type: Easing.InSine
				}
			}
		}
	}

	NavBar {
		id: navBar

		x: swipeViewLoader.x
		y: root.height + 4  // nudge below the visible area for wasm
		color: root.backgroundColor
		opacity: 0
		model: swipeView.contentModel

		onCurrentIndexChanged: if (swipeView) swipeView.setCurrentIndex(currentIndex)

		Component.onCompleted: pageManager.navBar = navBar

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

	StatusBar {
		id: statusBar

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
		color: root.backgroundColor
		notificationButtonsEnabled: swipePageModel.notificationsPage.isCurrentPage

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				root.controlsActive = true
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				root.controlsActive = false
				break;
			case VenusOS.StatusBar_LeftButton_Back:
				pageManager.popPage()
				break
			default:
				break
			}
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
