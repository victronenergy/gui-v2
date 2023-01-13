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

	Item {
		anchors.centerIn: parent
		clip: Qt.platform.os == "wasm"
		width: Theme.geometry.screen.width + wasmPadding
		height: Theme.geometry.screen.height

		// In WebAssembly builds, if we are displaying on a phone device,
		// the aspect ratio of the screen may not match the aspect ratio
		// expected on a CerboGX etc.
		// The phone web browser will auto zoom to horizontal-fill,
		// meaning that the vertical content may extend below the screen,
		// requiring vertical scroll to see.  This is suboptimal.
		// To fix, we need to add horizontal padding to match aspect.
		property real wasmPadding: {
			// no padding required if not on wasm
			if (Qt.platform.os != "wasm") {
				return 0
			}
			// no padding required if in portrait mode
			if (Screen.height > Screen.width) {
				return 0
			}
			// no padding required if the aspect ratio matches
			if ((Screen.height / Theme.geometry.screen.height)
					== (Screen.width / Theme.geometry.screen.width)) {
				return 0
			}
			// fix aspect ratio
			var verticalRatio = Screen.height / Theme.geometry.screen.height
			var expectedWidth = Theme.geometry.screen.width * verticalRatio
			var delta = Screen.width - expectedWidth
			if (delta < 0) {
				return 0
			}
			return delta
		}

		Loader {
			id: guiLoader

			anchors.centerIn: parent

			width: Theme.geometry.screen.width
			height: Theme.geometry.screen.height
			asynchronous: true
			focus: true

			active: Global.dataManagerLoaded
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

			active: Global.splashScreenVisible
			sourceComponent: Component {
				SplashView {
					anchors.centerIn: parent
				}
			}
		}
	}
}
