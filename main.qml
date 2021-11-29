/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Victron.Velib
import Victron.VenusOS
import "pages"
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

	StackView {
		id: pageStack
		anchors.fill: parent
		initialItem: "qrc:/pages/MainPage.qml"

		// Slide new drill-down pages in from the right
		pushEnter: Transition {
			PropertyAnimation {
				property: "x"
				from: width
				to: 0
				duration: 250
			}
		}
		pushExit: Transition {
			PropertyAnimation {
				property: "x"
				from: 0
				to: -width
				duration: 250
			}
		}
		popEnter: Transition {
			PropertyAnimation {
				property: "x"
				from: 0
				to: width
				duration: 250
			}
		}
		popExit: Transition {
			PropertyAnimation {
				property: "x"
				from: -width
				to: 0
				duration: 250
			}
		}
	}

	Connections {
		target: PageManager.emitter
		function onPagePushRequested(page) {
			pageStack.push(page)
		}
		function onPagePopRequested(page) {
			pageStack.pop()
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
