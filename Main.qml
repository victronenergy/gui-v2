/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window

// *** This file cannot be edited directly on the cerbo filesystem. It is loaded from the binary ***

Window {
	id: root

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")
	color: Global.allPagesLoaded && !!guiLoader.item ? guiLoader.item.mainView.backgroundColor : Theme.color_page_background

	width: Qt.platform.os != "wasm" ? Theme.geometry_screen_width/scaleFactor : Screen.width/scaleFactor
	height: Qt.platform.os != "wasm" ? Theme.geometry_screen_height/scaleFactor : Screen.height/scaleFactor

	property bool isDesktop: false
	property real scaleFactor: 1.0
	onIsDesktopChanged: Global.isDesktop = root.isDesktop

	function skipSplashScreen() {
		Global.splashScreenVisible = false
	}

	function rebuildUi() {
		console.warn("Rebuilding UI")
		if (Global.mainView) {
			Global.mainView.clearUi()
		}
		Global.reset()
		if (dataManagerLoader.active && dataManagerLoader.connectionReady) {
			// we haven't lost backend connection.
			// we must be rebuilding UI due to demo mode change.
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
		readonly property bool connectionReady: Global.backendReady
		onConnectionReadyChanged: {
			if (connectionReady) {
				active = true
			} else if (active && !Global.needPageReload) {
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

	contentItem {
		// on wasm just show the GUI at the top of the screen
		transformOrigin: Qt.platform.os !== "wasm" ? Item.Center : Item.Top

		// In WebAssembly builds, if we are displaying on a low-dpi mobile
		// device, it may not have enough pixels to display the UI natively.
		// To fix, we need to downscale everything by the appropriate factor,
		// and take into account browser chrome stealing real-estate also.
		onScaleChanged: Global.scalingRatio = contentItem.scale
		scale: Math.min(root.width/Theme.geometry_screen_width, root.height/Theme.geometry_screen_height)

		// Ideally each item would use focus handling to get its own key events, but in wasm the
		// pagestack's pages do not reliably receive key events even when focused.
		Keys.onPressed: function(event) {
			Global.keyPressed(event)
			event.accepted = false
		}
	}

	Loader {
		id: guiLoader

		clip: Qt.platform.os == "wasm" || Global.isDesktop
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height
		anchors.horizontalCenter: parent.horizontalCenter
		states: State {
			when: Qt.platform.os !== "wasm"
			AnchorChanges {
				target: guiLoader
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		asynchronous: true
		active: Global.dataManagerLoaded
		sourceComponent: ApplicationContent {
			anchors.centerIn: parent
		}
	}

	Loader {
		id: splashLoader

		clip: Qt.platform.os == "wasm"
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height
		anchors.horizontalCenter: parent.horizontalCenter
		states: State {
			when: Qt.platform.os !== "wasm"
			AnchorChanges {
				target: splashLoader
				anchors.verticalCenter: parent.verticalCenter
			}
		}

		active: Global.splashScreenVisible
		sourceComponent: SplashView {
			anchors.centerIn: parent
		}
	}

	FrameRateVisualizer {}
}
