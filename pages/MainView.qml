/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!pageManager.currentPage
			? pageManager.currentPage.backgroundColor
			: Theme.color_page_background

	property PageManager pageManager

	property int _loadedPages: 0

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded
	on_ReadyToInitChanged: {
		if (_readyToInit && pageStack.depth === 0) {
			_loadUi()
		}
	}

	function clearUi() {
		pageStack.clear()
		preloader.model = null
		_loadedPages = 0
	}

	function _loadUi() {
		console.warn("Data sources ready, loading pages")
		preloader.model = navBar.model
		navBar.currentIndex = 0
	}

	PageStack {
		id: pageStack

		property var previousItem
		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Connections {
			target: !!pageStack.currentItem ? pageStack.currentItem.C.StackView : null

			function onStatusChanged() {
				if (pageStack.currentItem.C.StackView.status === C.StackView.Deactivating) {
					pageStack.previousItem = pageStack.currentItem
				}
			}
		}

		Connections {
			target: pageManager.emitter

			function onPagePushRequested(obj, properties) {
				if (pageStack.busy) {
					return
				}

				let objectOrUrl = typeof(obj) === "string" ? Global.appUrl(obj) : obj

				// When pushing a settings sub-page, ensure nav bar is visible.
				if (navBar.currentIndex === navBar.model.count - 1 && objectOrUrl !== Global.appUrl("/pages/ControlCardsPage.qml")) {
					properties = properties || {}
					properties.height = pageStack.height - navBar.height
				}

				if (typeof(obj) === "string") {
					// pre-construct the object to make sure there are no errors
					// to avoid messing up the page stack state.
					let checkComponent = Qt.createComponent(objectOrUrl)
					if (checkComponent.status !== Component.Ready) {
						console.warn("Aborted attempt to push page with errors: " + obj + ": " + checkComponent.errorString())
						return
					}
					objectOrUrl = checkComponent.createObject(null, properties)
				}

				pageStack.push(objectOrUrl, properties) // at this point, MUST be an object, not URL.
			}

			function onPagePopRequested(toPage) {
				if (pageStack.busy
						|| (!!pageStack.currentItem.tryPop && !pageStack.currentItem.tryPop())) {
					return
				}
				let obj = pageStack.pop(toPage)
				if (!Theme.objectHasQObjectParent(obj)) {
					obj.destroy()
				}
			}
		}
	}

	Loader {
		id: controlCardsLoader

		onLoaded: pageManager._controlCardsPage = item
		onActiveChanged: if (active) active = true // remove binding

		z: 1
		opacity: 0.0
		source: Global.appUrl("/pages/ControlCardsPage.qml")
		active: pageManager.controlsActive
		enabled: pageManager.controlsActive || controlsOutAnimation.running

		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		SequentialAnimation {
			running: pageManager.controlsActive

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
					target: pageStack
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
			}
		}

		SequentialAnimation {
			id: controlsOutAnimation

			running: controlCardsLoader.active && !pageManager.controlsActive

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
					target: pageStack
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
			}
		}
	}

	StatusBar {
		id: statusBar

		title: !!pageManager.currentPage ? pageManager.currentPage.title || "" : ""
		leftButton: !!pageManager.currentPage? pageManager.currentPage.topLeftButton : VenusOS.StatusBar_LeftButton_None
		rightButton: !!pageManager.currentPage ? pageManager.currentPage.topRightButton : VenusOS.StatusBar_RightButton_None
		animationEnabled: BackendConnection.applicationVisible
		color: root.backgroundColor

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				pageManager.controlsActive = true
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				pageManager.controlsActive = false
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

	NavBar {
		id: navBar

		property real navbarX: pageStack.navbarX
		onNavbarXChanged: {
			if (!pageStack.currentItem || pageStack.depth < 1) {
				return
			}

			// If the settings page is active, and we are pushing a settings drill down
			// (rather than activating/deactivating the controls panel)
			// then don't allow the movement, i.e. keep navbar visible.
			if (currentIndex === (model.count -1)
					&& pageStack.currentItem.topLeftButton === VenusOS.StatusBar_LeftButton_ControlsInactive) {
				return
			}

			// Make the nav bar slide in/out along with the bottom page in the stack.
			x = navbarX
		}

		Behavior on x {
			XAnimator {
				duration: Theme.animation_page_slide_duration
				easing.type: Easing.InOutQuad
			}
		}

		y: root.height + 4  // nudge below the visible area for wasm
		color: root.backgroundColor
		opacity: 0

		onCurrentIndexChanged: {
			// For the main Brief/Overview/etc. pages, make room to show the nav bar at the bottom.
			const properties = { height: pageStack.height - navBar.height }
			pageStack.replace(null, preloader.itemAt(currentIndex).item, properties)
		}

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
					if (index === 0) {
						pageStack.push(item)
					}
					_loadedPages++
					if (_loadedPages === navBar.model.count) {
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
