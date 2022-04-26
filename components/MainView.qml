/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	readonly property color backgroundColor: !!pageStack.currentItem
			? pageStack.currentItem.backgroundColor
			: Theme.color.page.background

	property var pageManager

	StatusBar {
		id: statusBar

		title: !!pageStack.currentItem ? pageStack.currentItem.title || "" : ""

		navigationButton: !!pageStack.currentItem
				? pageStack.currentItem.navigationButton
				: VenusOS.StatusBar_NavigationButtonStyle_ControlsInactive
		navigationButtonEnabled: pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
		sidePanelButtonEnabled: pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& !!pageStack.currentItem && pageStack.currentItem.hasSidePanel

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

		Connections {
			target: Global
			function onReadyChanged() {
				if (Global.ready && pageStack.depth === 0) {
					pageStack.push("qrc:/pages/MainPage.qml")
				}
			}
		}

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
