/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property PageManager pageManager

	StatusBar {
		id: statusBar

		controlsVisible: pageManager.controlsVisible
		sidePanelVisible: pageManager.sidePanelVisible
		property bool hidden: statusBar.y === -statusBar.height
		property bool sidePanelWasVisible

		Component.onCompleted: pageManager.statusBar = statusBar

		onControlsActiveChanged: {
			if (controlsActive) {
				if (pageManager.sidePanelVisible) {
					statusBar.sidePanelWasVisible = true
				}
				pageManager.sidePanelVisible = false
				pageManager.pushPage("qrc:/pages/ControlCardsPage.qml")
			} else {
				pageManager.popPage()
				if (statusBar.sidePanelWasVisible) {
					pageManager.sidePanelVisible = true
				}
			}
		}

		onSidePanelActiveChanged: {
			pageManager.sidePanelActive = sidePanelActive
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

		pageManager: root.pageManager

		Connections {
			target: pageManager.emitter

			function onPagePushRequested() {
				pageStack.push(pageManager.pageToPush)
				pageManager.mainPageActive = pageStack.depth === 1
			}

			function onPagePopRequested() {
				pageStack.pop()
				pageManager.mainPageActive = pageStack.depth === 1
			}
		}
	}
}
