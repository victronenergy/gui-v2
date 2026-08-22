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
	property bool applicationActive: true // i.e. not in Idle mode
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
	readonly property bool animationEnabled: (Services.settings?.animationEnabled ?? true) && UiConfig.animationEnabled && UiConfig.applicationVisible && !ScreenBlanker.blanked
	readonly property bool timersEnabled: UiConfig.applicationVisible && !ScreenBlanker.blanked

	property bool allPagesLoaded
	property bool boatPageActive

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
		// note: we don't reset `main
		// as main will never be destroyed during the ui rebuild.
		pageManager = null
		mainView = null
		firmwareUpdate = null
		dialogLayer = null
		notificationLayer = null

		// The last thing we do is set the splash screen visible.
		allPagesLoaded = false
		UiConfig.splashScreenVisible = true
	}

	readonly property FontLoader _defaultFontLoader: FontLoader {
		source: Language.fontFileUrl
	}
	readonly property FontLoader _quantityFontLoader: FontLoader {
		source: "qrc:/fonts/Roboto-Regular.ttf"
	}

	readonly property IntValidator _intValidator: IntValidator {
	}
}

