/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data"

Window {
	id: root

	property Item battery: dbusData.item.battery
	property Item tanks: dbusData.item.tanks
	property Item generators: dbusData.item.generators

	property alias dialogManager: dialogManager

	width: [800, 1024][Theme.screenSize]
	height: [480, 600][Theme.screenSize]
	color: Theme.backgroundColor

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")

	StatusBar {
		id: statusBar

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
				duration: 250
				easing.type: Easing.InOutQuad
			}
			OpacityAnimator {
				target: statusBar
				from: 0.0
				to: 1.0
				duration: 250
				easing.type: Easing.InOutQuad
			}
		}

		SequentialAnimation {
			id: animateStatusBarOut
			OpacityAnimator {
				target: statusBar
				from: 1.0
				to: 0.0
				duration: 250
				easing.type: Easing.InOutQuad
			}
			NumberAnimation {
				target: statusBar
				property: "y"
				from: 0
				to: -statusBar.height
				duration: 250
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
			}

			function onPagePopRequested() {
				pageStack.pop()
			}
		}
	}

	DialogManager {
		id: dialogManager
	}

	Loader {
		id: dbusData

		active: dbusConnected
		sourceComponent: Item {
			property Battery battery: Battery {}
			property Tanks tanks: Tanks {}
			property Generators generators: Generators {}
			property Inverters inverters: Inverters {}
			property Relays relays: Relays {}

			VeQuickItem {
				id: veDBus
				uid: "dbus"
			}
			VeQuickItem {
				id: veSystem
				uid: "dbus/com.victronenergy.system"
			}
			VeQuickItem {
				id: veSettings
				uid: "dbus/com.victronenergy.settings"
			}
		}
	}
}
