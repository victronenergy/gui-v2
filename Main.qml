/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window

Window {
	id: root

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")
	color: Global.allPagesLoaded && !!guiLoader.item ? guiLoader.item.mainView.backgroundColor : Theme.color_page_background

	width: Qt.platform.os != "wasm" ? Theme.geometry_screen_width : Screen.width
	height: Qt.platform.os != "wasm" ? Theme.geometry_screen_height : Screen.height

	property bool isDesktop: false
	onIsDesktopChanged: Global.isDesktop = root.isDesktop

	function skipSplashScreen() {
		Global.allPagesLoaded = true
		Global.splashScreenVisible = false
	}

	function retranslateUi() {
		console.warn("Retranslating UI")
		// If we have to retranslate at startup prior to instantiating mainView
		// (because we load settings from the backend and discover that the
		//  device language is something other than "en_US")
		// then we don't need to tear down the UI before retranslating.
		// Otherwise, we have to rebuild the entire UI.
		if (Global.mainView) {
			console.warn("Retranslating requires rebuilding UI")
			rebuildUi()
		}
		Language.retranslate()
		Global.changingLanguage = false
		console.warn("Retranslating complete")
	}

	function rebuildUi() {
		console.warn("Rebuilding UI")
		if (Global.mainView) {
			Global.mainView.clearUi()
		}
		Global.reset()
		if (Global.changingLanguage || (dataManagerLoader.active && dataManagerLoader.connectionReady)) {
			// we haven't lost backend connection.
			// we must be rebuilding UI due to language or demo mode change.
			// manually cycle the data manager loader.
			dataManagerLoader.active = false
			dataManagerLoader.active = true
		}
		gc()
		console.warn("Rebuilding complete")
	}

	Component.onCompleted: Global.main = root

	Loader {
		id: dataManagerLoader
		readonly property bool connectionReady: BackendConnection.state === BackendConnection.Ready
		onConnectionReadyChanged: {
			if (connectionReady) {
				active = true
			} else if (active) {
				root.rebuildUi()
				active = false
			}
		}

		asynchronous: true
		active: false
		sourceComponent: Component {
			DataManager { }
		}
	}

	Item {
		anchors.horizontalCenter: parent.horizontalCenter
		width: Theme.geometry_screen_width + wasmPadding
		height: Theme.geometry_screen_height

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
			if ((Screen.height >= Theme.geometry_screen_height)
					&& (Screen.width >= Theme.geometry_screen_width)) {
				return 1.0
			}
			var hscale = Screen.width / Theme.geometry_screen_width
			var vscale = Screen.height / Theme.geometry_screen_height
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
			if ((Screen.height < Theme.geometry_screen_height)
					|| (Screen.width < Theme.geometry_screen_width)) {
				return 0
			}
			// no padding required if the aspect ratio matches
			if ((Screen.height / Theme.geometry_screen_height)
					== (Screen.width / Theme.geometry_screen_width)) {
				return 0
			}
			// fix aspect ratio
			var verticalRatio = Screen.height / Theme.geometry_screen_height
			var expectedWidth = Theme.geometry_screen_width * verticalRatio
			var chromeFactor = 1.2 // browser doesn't give whole screen to content area
			var delta = (Screen.width - expectedWidth) * chromeFactor
			if (delta < 0) {
				return 0
			}
			return Math.ceil(delta)
		}

		// Ideally each item would use focus handling to get its own key events, but in wasm the
		// pagestack's pages do not reliably receive key events even when focused.
		focus: true
		Keys.onPressed: function(event) {
			Global.keyPressed(event)
			event.accepted = false
		}

		Loader {
			id: guiLoader

			anchors.centerIn: parent

			width: Theme.geometry_screen_width
			height: Theme.geometry_screen_height
			asynchronous: true
			clip: Qt.platform.os == "wasm"

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
			width: Theme.geometry_screen_width
			height: Theme.geometry_screen_height
			clip: Qt.platform.os == "wasm"

			active: Global.splashScreenVisible
			sourceComponent: Component {
				SplashView {
					anchors.centerIn: parent
				}
			}
		}

		VenusFontLoader {
			id: fontLoader

			Component.onCompleted: Global.fontLoader = fontLoader
		}
	}

	FrameRateVisualizer {}
}
