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

	// Automatically decide if rotation is required (portrait -> landscape)
	readonly property bool requiresRotation: Global.isGxDevice && root.height > root.width
	property bool isDesktop: false
	property real scaleFactor: 1.0
	onIsDesktopChanged: Global.isDesktop = root.isDesktop

	// Uncomment for key navigation debugging
	// onActiveFocusItemChanged: console.info("** Active focused:", activeFocusItem, activeFocusItem?.title ?? activeFocusItem?.text ?? "")

	function skipSplashScreen() {
		Global.splashScreenVisible = false
	}

	function rebuildUi() {
		console.info("Main: UI rebuild required")
		if (Global.mainView) {
			Global.mainView.clearUi()
		}
		const requiresReloadData = dataManagerLoader.active && dataManagerLoader.connectionReady
		if (requiresReloadData) {
			// we haven't lost backend connection.
			// we must be rebuilding UI due to demo mode change,
			// or detected crash in localsettings/venus-platform.
			// manually cycle the data manager loader.
			console.info("Main: resetting data manager due to change requiring data reload")
			dataManagerLoader.active = false
		} else {
			console.info("Main: data reload not required")
		}
		Global.reset()
		gc()
		if (requiresReloadData) {
			dataManagerLoader.active = true
		}
		console.info("Main: UI rebuild started successfully")
	}

	function ensureApplicationActive() {
		Global.applicationActive = true
		appIdleTimer.restart()
	}

	function keyNavigationTimeout() {
		// Disable key nav when app is inactive; user can re-enable it later by pressing a
		// navigation key. Do not disable key nav when a dialog is shown, because the user
		// cannot re-enable it within a modal dialog, as ModalDialog focus is only enabled when
		// keyNavigationEnabled=true.
		if (!Global.dialogLayer?.currentDialog) {
			Global.keyNavigationEnabled = false
		}
	}

	Component.onCompleted: Global.main = root

	Loader {
		id: dataManagerLoader
		readonly property bool connectionReady: Global.backendReady
		onConnectionReadyChanged: {
			if (connectionReady) {
				console.info("Main: data backend ready has changed to true")
				active = true
			} else if (active && !Global.needPageReload) {
				console.info("Main: data backend ready has changed to false")
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
		// show the GUI always centered in the window
		transformOrigin: Item.Center

		// Apply rotation
		transform: Rotation {
			origin.x: root.width / 2
			origin.y: root.height / 2
			angle: root.requiresRotation ? 90 : 0
		}

		// Adjust scale depending on the rotation
		readonly property real rotatedScale: root.requiresRotation
			? Math.min(root.width / Theme.geometry_screen_height, root.height / Theme.geometry_screen_width)
			: Math.min(root.width / Theme.geometry_screen_width, root.height / Theme.geometry_screen_height)
		scale: rotatedScale

		// Center only if rotated
		x: root.requiresRotation ? (root.width - Theme.geometry_screen_height * contentItem.scale) / 2 : 0
		y: root.requiresRotation ? (root.height - Theme.geometry_screen_width * contentItem.scale) / 2 : 0

		// In WebAssembly builds, if we are displaying on a low-dpi mobile
		// device, it may not have enough pixels to display the UI natively.
		// To fix, we need to downscale everything by the appropriate factor,
		// and take into account browser chrome stealing real-estate also.
		onScaleChanged: Global.scalingRatio = contentItem.scale

		Keys.onPressed: function(event) {
			// Show or hide the console if necessary
			if ((Global.isGxDevice || Global.isDesktop)
					&& Global.systemSettings
					&& Global.systemSettings.canAccess(VenusOS.User_AccessType_SuperUser)) {
				if (event.key === Qt.Key_F1
						&& (event.modifiers & Qt.AltModifier
							|| event.modifiers & Qt.MetaModifier)) {
					consoleLoader.active = false
					event.accepted = true
					return
				} else if (event.key === Qt.Key_F2
						&& (event.modifiers & Qt.AltModifier
							|| event.modifiers & Qt.MetaModifier)) {
					consoleLoader.active = true
					event.accepted = true
					return
				}
			}

			// If a key press is not handled by an item higher up in the hierarchy:
			// Enable key navigation when an arrow or tab/backtab key is pressed.
			if (!Global.keyNavigationEnabled) {
				switch (event.key) {
				case Qt.Key_Left:
				case Qt.Key_Right:
				case Qt.Key_Up:
				case Qt.Key_Down:
				case Qt.Key_Tab:
				case Qt.Key_Backtab:
				case Qt.Key_Space:
					Global.keyNavigationEnabled = true
					event.accepted = true
					return
				}
			}
			event.accepted = false
		}
	}

	Loader {
		id: guiLoader

		// Receive key events if key navigation is enabled.
		focus: !consoleLoader.active
				&& Global.keyNavigationEnabled
				// Do not receive focus while a dialog is open, as the key events will cause the
				// focus item to change in the main UI.
				&& !Global.dialogLayer?.currentDialog

		clip: Qt.platform.os == "wasm" || Global.isDesktop
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height
		anchors.centerIn: parent

		asynchronous: true
		visible: !consoleLoader.active
		active: Global.dataManagerLoaded
		onActiveChanged: if (active) console.info("Main: data manager finished loading; now loading application content")
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
		anchors.centerIn: parent

		active: Global.splashScreenVisible
		sourceComponent: SplashView {
			anchors.centerIn: parent
		}
	}

	Loader {
		id: consoleLoader

		anchors.centerIn: parent
		width: Theme.geometry_screen_width
		height: Theme.geometry_screen_height

		asynchronous: true
		active: false
		focus: active

		source: Global.isGxDevice ? "qrc:/qt/qml/Victron/VenusOS/components/ConsoleTerminal.qml"
			: "qrc:/qt/qml/Victron/VenusOS/components/MockTerminal.qml"

		onStatusChanged: {
			if (status === Loader.Error) {
				console.error("Main: failed to load console:", source)
				consoleLoader.active = false
			}
		}

		Connections {
			target: consoleLoader.item
			function onFinished(ret) {
				consoleLoader.active = false
			}
		}
	}

	Timer {
		id: appIdleTimer
		running: !Global.splashScreenVisible && Global.timersEnabled
		interval: 60000
		onTriggered: {
			Global.applicationActive = false
			root.keyNavigationTimeout()
		}
	}

	// Detect when localsettings or venus-platform crashes
	// and trigger a rebuildUi() in those cases, as we
	// need to tear down all of our data models and rebuild them.
	Connections {
		id: systemServiceConnections
		target: SystemServiceListener
		property bool needReload: false
		property var toastId: null
		function onSettingsOnlineChanged() {
			if (Global.backendReady && !SystemServiceListener.settingsOnline) {
				console.info("Main: settings service is now unavailable!")
				if (!systemServiceConnections.needReload) {
					systemServiceConnections.needReload = true
					//% "Warning: detected localsettings service offline; reloading UI when it becomes available again..."
					systemServiceConnections.toastId = Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("main_system_service_settings_offline_warning"))
				}
			}

			if (SystemServiceListener.settingsOnline) {
				console.info("Main: settings service is available again")
				if (SystemServiceListener.platformOnline && systemServiceConnections.needReload) {
					console.info("Main: all required services are available, reloading UI")
					systemServiceConnections.needReload = false
					ToastModel.requestDismiss(systemServiceConnections.toastId)
					systemServiceConnections.toastId = null
					root.rebuildUi()
				}
			}
		}
		function onPlatformOnlineChanged() {
			if (Global.backendReady && !SystemServiceListener.platformOnline) {
				console.info("Main: platform service is now unavailable!")
				if (!systemServiceConnections.needReload) {
					systemServiceConnections.needReload = true
					//% "Warning: detected venus-platform service offline; reloading UI when it becomes available again..."
					systemServiceConnections.toastId = Global.showToastNotification(VenusOS.Notification_Warning, qsTrId("main_system_service_platform_offline_warning"))
				}
			}

			if (SystemServiceListener.platformOnline) {
				console.info("Main: platform service is available again")
				if (SystemServiceListener.settingsOnline && systemServiceConnections.needReload) {
					console.info("Main: all required services are available, reloading UI")
					systemServiceConnections.needReload = false
					ToastModel.requestDismiss(systemServiceConnections.toastId)
					systemServiceConnections.toastId = null
					root.rebuildUi()
				}
			}
		}
	}

	FrameRateVisualizer {}
}
