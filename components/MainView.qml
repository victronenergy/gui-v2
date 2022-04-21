/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property PageManager pageManager
	readonly property color backgroundColor: pageStack.currentItem.backgroundColor

	StatusBar {
		id: statusBar

		title: pageStack.currentItem.title || ""

		navigationButton:  pageStack.currentItem.navigationButton
		navigationButtonEnabled: pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
		sidePanelButtonEnabled: pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& pageStack.currentItem.hasSidePanel

		Component.onCompleted: pageManager.statusBar = statusBar

		onNavigationButtonClicked: {
			switch (navigationButton) {
			case VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive:
				pageManager.pushLayer("qrc:/pages/ControlCardsPage.qml")
				break
			case VenusOS.StatusBar_NavigationButtonStyle_ControlsActive:
				pageManager.popLayer()
				break
			case VenusOS.StatusBar_NavigationButtonStyle_Back:
				pageManager.popPage()
				break
			default:
				console.warn("Unrecognised navigation button", navigationButton)
				break
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

		focus: true
		pageManager: root.pageManager

		Connections {
			target: pageManager.emitter

			function onLayerPushRequested(obj, properties) {
				pageStack.push(obj, properties)
			}

			function onLayerPopRequested() {
				pageStack.pop()
			}
		}
	}
}
