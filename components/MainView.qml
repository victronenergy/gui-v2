/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	StatusBar {
		id: statusBar

		title: pageStack.currentItem.title || ""

		navigationButton:  pageStack.currentItem.navigationButton
		navigationButtonEnabled: PageManager.interactivity === PageManager.InteractionMode.Interactive
		sidePanelButtonEnabled: PageManager.interactivity === PageManager.InteractionMode.Interactive
				&& pageStack.currentItem.hasSidePanel

		Component.onCompleted: PageManager.statusBar = statusBar

		onNavigationButtonClicked: {
			switch (navigationButton) {
			case StatusBar.NavigationButton.ControlsInactive:
				PageManager.pushLayer("qrc:/pages/ControlCardsPage.qml")
				break
			case StatusBar.NavigationButton.ControlsActive:
				PageManager.popLayer()
				break
			case StatusBar.NavigationButton.Back:
				PageManager.popPage()
				break
			default:
				console.warn("Unrecognised navigation button", navigationButton)
				break
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

			function onLayerPushRequested(obj, properties) {
				pageStack.push(obj, properties)
				PageManager.mainPageActive = pageStack.depth === 1
			}

			function onLayerPopRequested() {
				pageStack.pop()
				PageManager.mainPageActive = pageStack.depth === 1
			}
		}
	}
}
