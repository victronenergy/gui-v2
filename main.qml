/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS
import "data" as Data

Window {
	id: root

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")
	color: Global.allPagesLoaded ? guiLoader.item.mainView.backgroundColor : Theme.color.page.background

	width: Theme.geometry.screen.width
	height: Theme.geometry.screen.height

	Loader {
		// Latch the Ready state so that it doesn't change if we later get disconnected.
		readonly property bool connectionReady: BackendConnection.state === BackendConnection.Ready
		onConnectionReadyChanged: if (connectionReady) active = true

		asynchronous: true
		active: false
		sourceComponent: Component {
			Data.DataManager { }
		}
	}

	Loader {
		id: guiLoader

		anchors.centerIn: parent
		width: Theme.geometry.screen.width
		height: Theme.geometry.screen.height
		clip: Qt.platform.os == "wasm"
		asynchronous: true
		focus: true

		active: Global.dataBackendLoaded
		sourceComponent: Component {
			ApplicationContent {
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
		sourceComponent: Component {
			SplashView {
				anchors.centerIn: parent
			}
		}
	}
}
