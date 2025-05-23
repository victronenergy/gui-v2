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

	function ensureApplicationActive() {
		Global.applicationActive = true
		appIdleTimer.restart()
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

		// #2161 Key nav is disabled for now
		// Keys.onPressed: function(event) {
		//     // When a navigation key is pressed and it is not handled by an item higher up in the
		//     // UI item hierarchy, enable key navigation to allow guiLoader to get focus and receive
		//     // key events.
		//     if (!Global.keyNavigationEnabled) {
		//         switch (event.key) {
		//         case Qt.Key_Left:
		//         case Qt.Key_Right:
		//         case Qt.Key_Up:
		//         case Qt.Key_Down:
		//         case Qt.Key_Tab:
		//         case Qt.Key_Backtab:
		//             Global.keyNavigationEnabled = true
		//             event.accepted = true
		//             return
		//         }
		//     }
		//     event.accepted = false
		// }
	}

	Loader {
		id: guiLoader

		// Receive key events if key navigation is enabled.
		focus: Global.keyNavigationEnabled
				// Do not receive focus while a dialog is open, as the key events will cause the
				// focus item to change in the main UI.
				&& !Global.dialogLayer?.currentDialog

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
			focus: true
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

	Timer {
		id: appIdleTimer
		running: !Global.splashScreenVisible
		interval: 60000
		onTriggered: {
			Global.applicationActive = false

			// Disable key nav when app is inactive; user can re-enable it later by pressing a
			// navigation key. Do not disable key nav when a dialog is shown, because the user
			// cannot re-enable it within a modal dialog, as ModalDialog focus is only enabled when
			// keyNavigationEnabled=true.
			if (!Global.dialogLayer?.currentDialog) {
				Global.keyNavigationEnabled = false
			}
		}
	}

	FrameRateVisualizer {}
}
