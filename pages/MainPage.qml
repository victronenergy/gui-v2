/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls as C
import Victron.VenusOS

Page {
	id: root

	property int _loadedPages: 0

	title: navStack.currentItem ? navStack.currentItem.title : ""
	navigationButton: navStack.depth > 1
			? VenusOS.StatusBar_NavigationButtonStyle_Back
			: VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
	hasSidePanel: navStack.currentItem ? navStack.currentItem.hasSidePanel : false
	backgroundColor: navStack.currentItem ? navStack.currentItem.backgroundColor : Theme.color.page.background
	fullScreenWhenIdle: navStack.currentItem ? navStack.currentItem.fullScreenWhenIdle : false

	Repeater {
		id: preloader // preload all of the pages to improve performance

		model: navBar.model
		Loader {
			y: root.height
			asynchronous: true
			source: url
			onStatusChanged: if (status === Loader.Ready) {
				if (index === 0) {
					navStack.push(item)
				}
				_loadedPages++
				if (_loadedPages === navBar.model.count) {
					Global.allPagesLoaded = true
				}
			}
		}
	}

	Connections {
		target: Global.pageManager ? Global.pageManager.emitter : null

		function onPagePushRequested(obj, properties) {
			navStack.push(obj, properties)
		}

		function onPagePopRequested() {
			navStack.pop()
		}
	}

	C.StackView {
		id: navStack
		clip: true
		focus: Global.pageManager.currentPage === root

		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			bottom: navBar.top
		}

		// Fade new navigation pages in
		replaceEnter: Transition {
			enabled: Global.allPagesLoaded

			OpacityAnimator {
				from: 0.0
				to: 1.0
				easing.type: Easing.InOutQuad
				duration: 250
			}
		}
		replaceExit: Transition {
			enabled: Global.allPagesLoaded

			OpacityAnimator {
				from: 1.0
				to: 0.0
				easing.type: Easing.InOutQuad
				duration: 250
			}
		}
	}


	NavBar {
		id: navBar

		opacity: 0
		y: root.height

		model: ListModel {
			ListElement {
				//% "Brief"
				text: QT_TRID_NOOP("nav_brief")
				icon: "qrc:/images/brief.svg"
				iconWidth: 28
				iconHeight: 28
				url: "qrc:/pages/BriefPage.qml"
			}
			ListElement {
				//% "Overview"
				text: QT_TRID_NOOP("nav_overview")
				icon: "qrc:/images/overview.svg"
				iconWidth: 28
				iconHeight: 22
				url: "qrc:/pages/OverviewPage.qml"
			}
			ListElement {
				//% "Levels"
				text: QT_TRID_NOOP("nav_levels")
				icon: "qrc:/images/levels.svg"
				iconWidth: 28
				iconHeight: 20
				url: "qrc:/pages/LevelsPage.qml"
			}
			ListElement {
				//% "Notifications"
				text: QT_TRID_NOOP("nav_notifications")
				icon: "qrc:/images/notifications.svg"
				iconWidth: 28
				iconHeight: 26
				url: "qrc:/pages/NotificationsPage.qml"
			}
			ListElement {
				//% "Settings"
				text: QT_TRID_NOOP("nav_settings")
				icon: "qrc:/images/settings.png"
				iconWidth: 24
				iconHeight: 24
				url: "qrc:/pages/SettingsPage.qml"
			}
		}

		property var currentUrl: navBar.model.get(0).url
		property var currentItem: navBar.model.get(0).item
		onCurrentUrlChanged: PageManager.sidePanelVisible = (currentUrl == navBar.model.get(0).url)

		onButtonClicked: function (buttonIndex) {
			var navUrl = model.get(buttonIndex).url
			if (navUrl != currentUrl) {
				currentUrl = navUrl
				navStack.replace(null, preloader.itemAt(buttonIndex).item)
			}
		}

		SequentialAnimation {
			running: !Global.splashScreenVisible

			PauseAnimation {
				duration: Theme.animation.navBar.initialize.delayedStart.duration
			}
			ParallelAnimation {
				NumberAnimation {
					target: navBar
					property: "y"
					from: root.height - navBar.height + Theme.animation.navBar.initialize.margin
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

			running: Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen
					 || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_ExitIdleMode

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
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_ExitIdleMode
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
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Interactive
				}
			}
		}

		SequentialAnimation {
			id: animateNavBarOut

			running: Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_EnterIdleMode
					 || Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen

			OpacityAnimator {
				target: navBar
				from: 1.0
				to: 0.0
				duration: Theme.animation.page.idleOpacity.duration
				easing.type: Easing.InOutQuad
			}
			ScriptAction {
				script: {
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_BeginFullScreen
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
					Global.pageManager.interactivity = VenusOS.PageManager_InteractionMode_Idle
				}
			}
		}
	}

	Component.onCompleted: Global.pageManager.navBar = navBar
}
