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

		Component.onCompleted: PageManager.statusBar = statusBar

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
