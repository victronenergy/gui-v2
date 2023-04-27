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

	width: Qt.platform.os != "wasm" ? Theme.geometry.screen.width : Screen.width
	height: Qt.platform.os != "wasm" ? Theme.geometry.screen.height : Screen.height

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
		anchors.horizontalCenter: parent.horizontalCenter
		clip: Qt.platform.os == "wasm"
		width: Theme.geometry.screen.width + wasmPadding
		height: Theme.geometry.screen.height

		// on wasm just show the GUI at the top of the screen,
		// otherwise browser chrome can cause problems on mobile devices...
		y: (Qt.platform.os != "wasm" || scale == 1.0) ? (parent.height-height)/2 : 0
		transformOrigin: Qt.platform.os != "wasm" ? Item.Center : Item.Top

		// In WebAssembly builds, if we are displaying on a low-dpi mobile
		// device, it may not have enough pixels to display the UI natively.
		// To fix, we need to downscale everything by the appropriate factor,
		// and take into account browser chrome stealing real-estate also.
		scale: {
			// no scaling required if not on wasm
			if (Qt.platform.os != "wasm") {
				return 1.0
			}
			// no scaling required if we can pad and zoom instead
			if ((Screen.height >= Theme.geometry.screen.height)
					&& (Screen.width >= Theme.geometry.screen.width)) {
				return 1.0
			}
			var hscale = Screen.width / Theme.geometry.screen.width
			var vscale = Screen.height / Theme.geometry.screen.height
			// in landscape mode, give even more room, as the browser chrome
			// will take up significant vertical space.
			var chromeFactor = (Screen.height > Screen.width) ? 1.0 : 0.75
			return Math.min(hscale, vscale) * chromeFactor
		}

		// In WebAssembly builds, if we are displaying on a high-dpi mobile
		// device the aspect ratio of the screen may not match the aspect
		// ratio expected on a CerboGX etc.
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
			// no padding required if we need to downscale
			if ((Screen.height < Theme.geometry.screen.height)
					|| (Screen.width < Theme.geometry.screen.width)) {
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
			var chromeFactor = 1.2 // browser doesn't give whole screen to content area
			var delta = (Screen.width - expectedWidth) * chromeFactor
			if (delta < 0) {
				return 0
			}
			return Math.ceil(delta)
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

	FrameRateVisualizer {}
}
