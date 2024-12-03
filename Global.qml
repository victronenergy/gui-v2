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
	property var mockDataSimulator    // only valid when mock mode is active
	property var dataManager
	property VeQItemTableModel dataServiceModel: null
	property var firmwareUpdate
	property var allDevicesModel
	property bool applicationActive: true

	readonly property string fontFamily: _defaultFontLoader.name
	readonly property string quantityFontFamily: _quantityFontLoader.name
	property var dialogLayer
	property var notificationLayer
	property ScreenBlanker screenBlanker
	property bool displayCpuUsage
	property bool pauseElectronAnimations

	// data sources
	property var acInputs
	property var acSystemDevices
	property var chargers
	property var batteries
	property var dcInputs
	property var dcLoads
	property var digitalInputs
	property var environmentInputs
	property var ess
	property var evChargers
	property var generators
	property var inverterChargers
	property var notifications
	property var pvInverters
	property var solarChargers
	property var system
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

	property bool animationEnabled: true // for mock mode only.

	readonly property int int32Max: _intValidator.top
	readonly property int int32Min: _intValidator.bottom

	signal aboutToFocusTextField(var textField, var textFieldContainer, var flickable)
	signal keyPressed(var event)

	function showToastNotification(category, text, autoCloseInterval = 0) {
		if (!!notificationLayer) {
			return notificationLayer.showToastNotification(category, text, autoCloseInterval)
		}
		return null
	}

	function deviceModelsForClass(deviceClass) {
		if (deviceClass === "com.victronenergy.battery") {
			return [batteries.model]
		} else if (deviceClass === "com.victronenergy.solarcharger" || deviceClass === "solarcharger") {
			return [solarChargers.model]
		} else if (deviceClass === "analog") {
			return Global.tanks.allTankModels.concat([Global.environmentInputs.model])
		}
		return []
	}

	function reset() {
		// unload the gui.
		dataManagerLoaded = false

		// note: we don't reset `main
		// as main will never be destroyed during the ui rebuild.
		pageManager = null
		mainView = null
		mockDataSimulator = null
		dataManager = null
		dataServiceModel = null
		firmwareUpdate = null
		allDevicesModel = null
		dialogLayer = null
		notificationLayer = null

		acInputs = null
		acSystemDevices = null
		chargers = null
		batteries = null
		dcInputs = null
		dcLoads = null
		digitalInputs = null
		environmentInputs = null
		ess = null
		evChargers = null
		generators = null
		inverterChargers = null
		notifications = null
		pvInverters = null
		solarChargers = null
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
}

