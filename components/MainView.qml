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

	readonly property bool _readyToInit: !!Global.pageManager && Global.dataManagerLoaded
	on_ReadyToInitChanged: {
		if (_readyToInit && pageStack.depth === 0) {
			console.warn("Data sources ready, creating MainPage.qml")
			pageStack.push("qrc:/pages/MainPage.qml")
		}
	}

	StatusBar {
		id: statusBar

		title: !!pageStack.currentItem ? pageStack.currentItem.title || "" : ""
		leftButton: !!pageStack.currentItem ? pageStack.currentItem.topLeftButton : VenusOS.StatusBar_LeftButton_None
		rightButton: !!pageStack.currentItem ? pageStack.currentItem.topRightButton : VenusOS.StatusBar_RightButton_None

		Component.onCompleted: pageManager.statusBar = statusBar

		onLeftButtonClicked: {
			switch (leftButton) {
			case VenusOS.StatusBar_LeftButton_ControlsInactive:
				pageManager.pushLayer("qrc:/pages/ControlCardsPage.qml")
				break
			case VenusOS.StatusBar_LeftButton_ControlsActive:
				pageManager.popLayer()
				break
			case VenusOS.StatusBar_LeftButton_Back:
				pageManager.popPage()
				break
			default:
				break
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

		focus: true

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
