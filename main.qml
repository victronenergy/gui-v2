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
	color: Global.guiLoaded ? guiLoader.item.mainView.backgroundColor : Theme.color.page.background

	width: Theme.geometry.screen.width
	height: Theme.geometry.screen.height

	Loader {
		id: dataManagerLoader

		asynchronous: true
		active: Global.backendConnectionReady
		sourceComponent: dataLoader

		Component {
			id: dataLoader
			DataLoader { }
		}
	}

	Loader {
		id: guiLoader

		anchors.centerIn: parent
		width: Theme.geometry.screen.width
		height: Theme.geometry.screen.height
		clip: Qt.platform.os == "wasm"
		asynchronous: true

		active: Global.dataBackendLoaded
		sourceComponent: applicationContent
		onLoaded: Global.guiLoaded = true

		Component {
			id: applicationContent

			ApplicationContent {
				id: content
				anchors.centerIn: parent
			}
		}
	}

	Loader {
		id: splashLoader

		anchors.centerIn: parent
		width: Theme.geometry.screen.width
		height: Theme.geometry.screen.height
		clip: Qt.platform.os == "wasm"

		active: Global.splashScreenVisible
		sourceComponent: splashView

		Component {
			id: splashView
			SplashView {
				anchors.centerIn: parent
				// Latch the Ready state so that it doesn't change if we later get disconnected.
				property bool connectionReady: BackendConnection.state == BackendConnection.Ready
				onConnectionReadyChanged: if (connectionReady) Global.backendConnectionReady = true
			}
		}
	}
}
