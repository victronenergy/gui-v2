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

	width: Qt.platform.os != "wasm" ? Theme.geometry_screen_width : Screen.width
	height: Qt.platform.os != "wasm" ? Theme.geometry_screen_height : Screen.height

	property bool isDesktop: false
	onIsDesktopChanged: Global.isDesktop = root.isDesktop

	function skipSplashScreen() {
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

	contentItem {
		// on wasm just show the GUI at the top of the screen
		transformOrigin: Qt.platform.os !== "wasm" ? Item.Center : Item.Top

		// In WebAssembly builds, if we are displaying on a low-dpi mobile
		// device, it may not have enough pixels to display the UI natively.
		// To fix, we need to downscale everything by the appropriate factor,
		// and take into account browser chrome stealing real-estate also.
		onScaleChanged: Global.scalingRatio = contentItem.scale
		scale: Math.min(1.0, root.width/Theme.geometry_screen_width, root.height/Theme.geometry_screen_height)

		// Ideally each item would use focus handling to get its own key events, but in wasm the
		// pagestack's pages do not reliably receive key events even when focused.
		Keys.onPressed: function(event) {
			Global.keyPressed(event)
			event.accepted = false
		}
	}

	Loader {
		id: guiLoader

		clip: Qt.platform.os == "wasm"
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

	FontLoader {
		id: fontLoader

		source: Language.fontFileUrl
		Component.onCompleted: Global.fontLoader = fontLoader
	}

	FontLoader {
		source: "qrc:/fonts/MuseoSans-500-monospaced-digits.otf"
	}

	FrameRateVisualizer {}
}
