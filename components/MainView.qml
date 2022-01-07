/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	StatusBar {
		id: statusBar

		controlsVisible: PageManager.controlsVisible
		sidePanelVisible: PageManager.sidePanelVisible
		property bool hidden: statusBar.y === -statusBar.height
		property bool sidePanelWasVisible

		onControlsActiveChanged: {
			if (controlsActive) {
				if (PageManager.sidePanelVisible) {
					statusBar.sidePanelWasVisible = true
				}
				PageManager.sidePanelVisible = false
				PageManager.pushPage("qrc:/pages/ControlCardsPage.qml")
			} else {
				PageManager.popPage()
				if (statusBar.sidePanelWasVisible) {
					PageManager.sidePanelVisible = true
				}
			}
		}

		onSidePanelActiveChanged: {
			PageManager.sidePanelActive = sidePanelActive
		}

		function show() {
			if (hidden) {
				animateStatusBarIn.start()
			}
		}

		function hide() {
			if (!hidden) {
				animateStatusBarOut.start()
			}
		}

		SequentialAnimation {
			id: animateStatusBarIn
			NumberAnimation {
				target: statusBar
				property: "y"
				from: -statusBar.height
				to: 0
				duration: Theme.animation.statusBar.slide.duration
				easing.type: Easing.InOutQuad
			}
			OpacityAnimator {
				target: statusBar
				from: 0.0
				to: 1.0
				duration: Theme.animation.statusBar.fade.duration
				easing.type: Easing.InOutQuad
			}
		}

		SequentialAnimation {
			id: animateStatusBarOut
			OpacityAnimator {
				target: statusBar
				from: 1.0
				to: 0.0
				duration: Theme.animation.statusBar.fade.duration
				easing.type: Easing.InOutQuad
			}
			NumberAnimation {
				target: statusBar
				property: "y"
				from: 0
				to: -statusBar.height
				duration: Theme.animation.statusBar.slide.duration
				easing.type: Easing.InOutQuad
			}
		}
	}

	PageStack {
		id: pageStack
		anchors {
			top: statusBar.bottom
			left: parent.left
			right: parent.right
			bottom: parent.bottom
		}

		Connections {
			target: PageManager.emitter

			function onPagePushRequested() {
				pageStack.push(PageManager.pageToPush)
				PageManager.mainPageActive = pageStack.depth === 1
			}

			function onPagePopRequested() {
				pageStack.pop()
				PageManager.mainPageActive = pageStack.depth === 1
			}
		}
	}
}
