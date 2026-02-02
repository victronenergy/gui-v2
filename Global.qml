/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQuick
import Victron.VenusOS

QtObject {
	property var main
	property var pageManager
	property var mainView
	property var firmwareUpdate
	property bool applicationActive: true
	property bool keyNavigationEnabled

	readonly property bool backendReady: BackendConnection.state === BackendConnection.Ready
		&& (Qt.platform.os !== "wasm"
			|| !BackendConnection.vrm
			|| BackendConnection.heartbeatState !== BackendConnection.HeartbeatInactive)
	readonly property string fontFamily: _defaultFontLoader.name
	readonly property string quantityFontFamily: _quantityFontLoader.name
	property var dialogLayer
	property var notificationLayer
	property bool displayCpuUsage
	readonly property bool animationEnabled: (systemSettings?.animationEnabled ?? true) && BackendConnection.applicationVisible

	// data sources
	property var acInputs
	property var dcInputs
	property var environmentInputs
	property var evChargers
	property var generators
	property var inverterChargers
	property var notifications
	property var solarInputs
	property var system
	property var switches
	property var systemSettings
	property var tanks

	property var venusPlatform
	property bool splashScreenVisible: true
	property bool dataManagerLoaded
	property bool allPagesLoaded

	property string firmwareInstalledBuild // don't clear this on UI reload.  it needs to survive reconnection.
	property bool firmwareInstalledBuildUpdated // as above.
	property bool needPageReload: Qt.platform.os == "wasm" && firmwareInstalledBuildUpdated // as above.

	property bool isDesktop
	property bool isGxDevice: Qt.platform.os === "linux" && !isDesktop
	property real scalingRatio: 1.0

	readonly property int int32Max: _intValidator.top
	readonly property int int32Min: _intValidator.bottom

	property bool backendReadyLatched
	onBackendReadyChanged: if (backendReady) backendReadyLatched = true

	signal aboutToFocusTextField(var textField, var textFieldContainer, var viewToScroll)

	function showToastNotification(type, text, autoCloseInterval = 0) {
		return ToastModel.add(type, text, autoCloseInterval)
	}

	function reset() {
		// unload the gui.
		dataManagerLoaded = false

		// note: we don't reset `main
		// as main will never be destroyed during the ui rebuild.
		pageManager = null
		mainView = null
		firmwareUpdate = null
		dialogLayer = null
		notificationLayer = null

		acInputs = null
		dcInputs = null
		environmentInputs = null
		evChargers = null
		generators = null
		inverterChargers = null
		notifications = null
		solarInputs = null
		system = null
		systemSettings = null
		tanks = null
		venusPlatform = null

		// The last thing we do is set the splash screen visible.
		allPagesLoaded = false
		splashScreenVisible = true
	}

	readonly property FontLoader _defaultFontLoader: FontLoader {
		source: Language.fontFileUrl
	}
	readonly property FontLoader _quantityFontLoader: FontLoader {
		source: "qrc:/fonts/Roboto-Regular.ttf"
	}

	readonly property IntValidator _intValidator: IntValidator {
	}

/*
	readonly property VeQuickItem _guiPlugins: VeQuickItem {
		// Only listen to the gui plugins MQTT path in WASM.
		// GX and Desktop builds read gui plugins from filesystem instead.
		// TODO: update the path to the correct MQTT-only path once it is decided.
		uid: (Qt.platform.os === "wasm")
			? pluginsService.serviceUid + "/Gui2/Plugins"
			: ""
		property string json: valid && BackendConnection.state === BackendConnection.Ready ? value : "[]"
		onJsonChanged: {
			// don't unload plugins if we lose backend data connection.
			if (Qt.platform.os === "wasm" && BackendConnection.state === BackendConnection.Ready) {
				GuiPluginLoader.pluginsJson = json
			}
		}
	}
*/
}

