/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls as C
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!pageStack.currentItem
			? pageStack.currentItem.backgroundColor
			: Theme.color.page.background

	property var pageManager

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
				// When pushing a settings sub-page, ensure nav bar is visible.
				if (navBar.currentIndex === navBar.model.count - 1 && obj !== "qrc:/pages/ControlCardsPage.qml") {
					properties = properties || {}
					properties.height = pageStack.height - navBar.height
				}
				pageStack.push(obj, properties)
			}

			function onPagePopRequested(toPage) {
				if (pageStack.busy
						|| (!!pageStack.currentItem.tryPop && !pageStack.currentItem.tryPop())) {
					return
				}
				pageStack.pop(toPage)
			}
		}
	}

	StatusBar {
		id: statusBar

		title: !!pageStack.currentItem ? pageStack.currentItem.title || "" : ""
		leftButton: !!pageStack.currentItem ? pageStack.currentItem.topLeftButton : VenusOS.StatusBar_LeftButton_None
		rightButton: !!pageStack.currentItem ? pageStack.currentItem.topRightButton : VenusOS.StatusBar_RightButton_None
		animationEnabled: BackendConnection.applicationVisible
		color: root.backgroundColor

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				pageManager.pushPage("qrc:/pages/ControlCardsPage.qml")
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:   // fall through
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

		x: {
			if (!pageStack.currentItem || pageStack.depth < 1) {
				return 0
			}
			if (currentIndex === model.count - 1
					&& pageStack.currentItem.topLeftButton !== VenusOS.StatusBar_LeftButton_ControlsActive
					&& (!pageStack.previousItem || pageStack.previousItem.topLeftButton !== VenusOS.StatusBar_LeftButton_ControlsActive)) {
				// Stack is showing a settings sub-page, so keep the nav bar visible.
				return 0
			}
			// Make the nav bar slide in/out along with the bottom page in the stack.
			return pageStack.get(0).x
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

			PauseAnimation {
				duration: Theme.animation.navBar.initialize.delayedStart.duration
			}
			ParallelAnimation {
				NumberAnimation {
					target: navBar
					property: "y"
					from: root.height - navBar.height + Theme.geometry.navigationBar.initialize.margin
					to: root.height - navBar.height
					duration: Theme.animation.navBar.initialize.fade.duration
				}
				NumberAnimation {
					target: navBar
					property: "opacity"
					to: 1
					duration: Theme.animation.navBar.initialize.fade.duration
				}
			}
		}

		SequentialAnimation {
			id: animateNavBarIn

			running: !!Global.pageManager && (Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
					 || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode)

			NumberAnimation {
				target: navBar
				property: "y"
				from: root.height
				to: root.height - navBar.height
				duration: Theme.animation.page.idleResize.duration
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
				duration: Theme.animation.page.idleOpacity.duration
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
				duration: Theme.animation.page.idleOpacity.duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					if (!!Global.pageManager) {
						Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_BeginFullScreen
					}
				}
			}
			NumberAnimation {
				target: navBar
				property: "y"
				from: root.height - navBar.height
				to: root.height
				duration: Theme.animation.page.idleResize.duration
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
