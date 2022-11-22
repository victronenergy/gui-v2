/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

Window {
	id: root

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")
	color: loader.sourceComponent === applicationContent && loader.status === Loader.Ready ? loader.item.mainView.backgroundColor : Theme.color.page.background

	width: Theme.geometry.screen.width
	height: Theme.geometry.screen.height

	Loader {
		id: loader
		anchors.fill: parent
		sourceComponent: Global.splashScreenVisible ? splashView : applicationContent
	}

	Component {
		id: splashView

		SplashView {
			anchors.fill: parent
		}
	}

	Component {
		id: applicationContent

		ApplicationContent {
			id: content
			anchors.centerIn: parent
			width: Theme.geometry.screen.width
			height: Theme.geometry.screen.height
			clip: Qt.platform.os == "wasm"
		}
	}
}
