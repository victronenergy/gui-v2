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
	property var pressEffect
	property bool displayCpuUsage
	readonly property bool animationEnabled: (systemSettings?.animationEnabled ?? true) && UiConfig.animationEnabled && UiConfig.applicationVisible && !ScreenBlanker.blanked
	readonly property bool timersEnabled: UiConfig.applicationVisible && !ScreenBlanker.blanked

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
	property bool dataManagerLoaded
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

	signal aboutToFocusTextField(textField : Item, viewToScroll : Flickable)

	function showToastNotification(type, text, autoCloseInterval = 0) {
		return ToastModel.add(type, text, autoCloseInterval)
	}

	// Returns the url of the device settings page for the service type of the given uid, or an
	// empty string if there is no page for that service type.
	function devicePageUrl(serviceUid) {
		switch (BackendConnection.serviceTypeFromUid(serviceUid)) {
		case "acload":
		case "grid":
		case "heatpump":
		case "pvinverter":
			return "/pages/settings/devicelist/ac-in/PageAcIn.qml"
		case "acsystem":
			return "/pages/settings/devicelist/rs/PageRsSystem.qml"
		case "alternator":
			return "/pages/settings/devicelist/dc-in/PageAlternator.qml"
		case "battery":
			return "/pages/settings/devicelist/battery/PageBattery.qml"
		case "charger":
			return "/pages/settings/devicelist/PageAcCharger.qml"
		case "dcdc":
			return "/pages/settings/devicelist/dc-in/PageDcDcConverter.qml"
		case "dcload":
		case "dcsource":
		case "dcsystem":
		case "fuelcell":
			return "/pages/settings/devicelist/dc-in/PageDcMeter.qml"
		case "dcgenset":
		case "genset":
			return "/pages/settings/devicelist/PageGenset.qml"
		case "digitalinput":
			return "/pages/settings/devicelist/PageDigitalInput.qml"
		case "ev":
			return "/pages/ev/EvPage.qml"
		case "evcharger":
			return "/pages/evcs/EvChargerPage.qml"
		case "gps":
			return "/pages/settings/PageGps.qml"
		case "inverter":
			return "/pages/settings/devicelist/inverter/PageInverter.qml"
		case "meteo":
			return "/pages/settings/devicelist/PageMeteo.qml"
		case "motordrive":
			return "/pages/settings/devicelist/PageMotorDrive.qml"
		case "multi":
			return "/pages/settings/devicelist/rs/PageMultiRs.qml"
		case "pulsemeter":
			return "/pages/settings/devicelist/pulsemeter/PagePulseCounter.qml"
		case "solarcharger":
			return "/pages/solar/PageSolarCharger.qml"
		case "switch":
			return "/pages/settings/devicelist/PageSwitch.qml"
		case "tank":
			return "/pages/settings/devicelist/tank/PageTankSensor.qml"
		case "temperature":
			return "/pages/settings/devicelist/temperature/PageTemperatureSensor.qml"
		case "unsupported":
			return "/pages/settings/devicelist/PageUnsupportedDevice.qml"
		case "vebus":
			return "/pages/vebusdevice/PageVeBus.qml"
		default:
			return ""
		}
	}

	// Pushes the device settings page for the service type of the given uid. The page's uid
	// property (bindPrefix or serviceUid, depending on the page) is set automatically; any other
	// properties are passed through to the page.
	// Returns the pushed page, or null if there is no page for that service type.
	function openDevicePage(serviceUid, properties = {}) {
		const pageUrl = devicePageUrl(serviceUid)
		if (pageUrl.length === 0) {
			console.warn("No device page available for service:", serviceUid)
			return null
		}
		const uidProperty = BackendConnection.serviceTypeFromUid(serviceUid) === "switch" ? "serviceUid" : "bindPrefix"
		const pageProperties = Object.assign({ [uidProperty]: serviceUid }, properties)
		return pageManager.pushPage(pageUrl, pageProperties)
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
		pressEffect = null

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

