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
			   : swipeView.currentItem

	// To reduce the animation load, disable page animations when the PageStack is transitioning
	// between pages, or when flicking between the main pages. Note that animations are still
	// allowed when dragging between the main pages, as it looks odd if animations stop abruptly
	// when the user drags slowly between pages.
	readonly property bool allowPageAnimations: BackendConnection.applicationVisible
			&& !pageStack.busy && !swipeView.flicking
			&& !Global.splashScreenVisible

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded
	on_ReadyToInitChanged: {
		if (_readyToInit && swipeView.count === 0) {
			_loadUi()
		}
	}

	function clearUi() {
		while (swipeView.count > 0) {
			swipeView.removeItem(swipeView.itemAt(swipeView.count - 1))
		}
		pageStack.clear()
		preloader.model = null
		_loadedPages = 0
	}

	function _loadUi() {
		console.warn("Data sources ready, loading pages")
		preloader.model = navBar.model
		navBar.setCurrentPage("BriefPage.qml")
	}

	// This SwipeView contains the main application pages (Brief, Overview, Levels, Notifications,
	// and Settings).
	SwipeView {
		id: swipeView

		// Anchor this to the PageStack's left side, so that this view slides out of view when the
		// PageStack slides in (and vice-versa), giving the impression that the SwipeView itself
		// is part of the stack.
		anchors {
			top: statusBar.bottom
			bottom: navBar.top
			right: pageStack.left
		}
		width: Theme.geometry_screen_width
		onCurrentIndexChanged: {
			navBar.setCurrentIndex(currentIndex)
		}
	}

	Loader {
		id: controlCardsLoader

		onActiveChanged: if (active) active = true // remove binding

		z: 1
		opacity: 0.0
		source: Global.appUrl("/pages/ControlCardsPage.qml")
		active: root.controlsActive
		enabled: root.controlsActive || controlsOutAnimation.running

		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		SequentialAnimation {
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

		x: swipeView.x
		y: root.height + 4  // nudge below the visible area for wasm
		color: root.backgroundColor
		opacity: 0

		onCurrentIndexChanged: swipeView.currentIndex = currentIndex

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

	Repeater {
		id: preloader // preload all of the pages to improve performance

		model: null

		Loader {
			y: root.height + 4 // avoid fractional scaling smearing a row of pixels into visible area
			asynchronous: true
			visible: false
			source: url

			onStatusChanged: {
				if (status === Loader.Ready) {
					_loadedPages++
					if (_loadedPages === navBar.model.count) {
						for (let i = 0; i < preloader.count; ++i) {
							swipeView.addItem(preloader.itemAt(i).item)
						}
						Global.allPagesLoaded = true
					}
				} else if (status === Loader.Error) {
					console.warn("Error preloading page: " + source.toString())
				} else {
					console.log("Preloading page: " + source.toString())
				}
			}
		}
	}
}
