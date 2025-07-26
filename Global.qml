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
	property var dataManager
	property VeQItemTableModel dataServiceModel: null
	property var firmwareUpdate
	property var allDevicesModel
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
	property ScreenBlanker screenBlanker
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

	signal aboutToFocusTextField(var textField, var textFieldContainer, var flickable)

	function showToastNotification(category, text, autoCloseInterval = 0) {
		if (!!notificationLayer) {
			return notificationLayer.showToastNotification(category, text, autoCloseInterval)
		}
		return null
	}

	function reset() {
		// unload the gui.
		dataManagerLoaded = false

		// note: we don't reset `main
		// as main will never be destroyed during the ui rebuild.
		pageManager = null
		mainView = null
		dataManager = null
		dataServiceModel = null
		firmwareUpdate = null
		allDevicesModel = null
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

	readonly property VeQuickItem _customisations: VeQuickItem {
		uid: (systemSettings && systemSettings.serviceUid.length > 0)
			? systemSettings.serviceUid + "/Gui2/Customisations"
			: ""
		property string json: valid ? value
			: debugJson // DEBUGGING ONLY

		property string debugJson: "[" + debug_simpleJson + "," + debug_simpleTrJson + "]"
		property string debug_simpleJson: '
{
	"name": "Simple",
	"version": "Simple",
	"minRequiredVersion": "v1.2.7",
	"maxRequiredVersion": "",
	"translations": [
		"qrc:/Simple/Simple_en.qm"
	],
	"integrations": [
		{
			"type": 1,
			"url": "qrc:/Simple/Simple_PageSettingsSimple.qml"
		}
	],
	"resource": "cXJlcwAAAAMAAAH+AAAAGAAAAY4AAAAAAAAAITy4ZBjK75yVzSEcv2Chvd2nAAAABWVuX1VTiAAAAAIBAQAAAU1pbXBvcnQgUXRRdWljawppbXBvcnQgVmljdHJvbi5WZW51c09TCgpQYWdlIHsKCWlkOiByb290CgoJdGl0bGU6ICJTaW1wbGUiCgoJR3JhZGllbnRMaXN0VmlldyB7CgkJaWQ6IHNldHRpbmdzTGlzdFZpZXcKCgkJbW9kZWw6IFZpc2libGVJdGVtTW9kZWwgewoJCQlMaXN0U3dpdGNoIHsKCQkJCXRleHQ6ICJTd2l0Y2giCgkJCQlwcm9wZXJ0eSBib29sIHZhbHVlCgkJCQljaGVja2VkOiB2YWx1ZQoJCQkJb25DbGlja2VkOiB7CgkJCQkJdmFsdWUgPSAhY2hlY2tlZAoJCQkJCWNvbnNvbGUubG9nKCJTd2l0Y2ggbm93IGNoZWNrZWQ/IiwgY2hlY2tlZCkKCQkJCX0KCQkJfQoJCX0KCX0KfQoABgWgRyUAUwBpAG0AcABsAGUADAAcmz0AUwBpAG0AcABsAGUAXwBlAG4ALgBxAG0AHQSI5lwAUwBpAG0AcABsAGUAXwBQAGEAZwBlAFMAZQB0AHQAaQBuAGcAcwBTAGkAbQBwAGwAZQAuAHEAbQBsAAAAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAAAAgAAAAIAAAACAAAAAAAAAAAAAAASAAAAAAABAAAAAAAAAZg8I71qAAAAMAAAAAAAAQAAACUAAAGYPB9q3A=="
}'
		property string debug_simpleTrJson: '
{
    "name": "SimpleTr",
    "version": "SimpleTr",
    "minRequiredVersion": "v1.2.7",
    "maxRequiredVersion": "",
    "translations": [
        "qrc:/SimpleTr/SimpleTr_fr.qm",
        "qrc:/SimpleTr/SimpleTr_en.qm"
    ],
    "integrations": [
        {
            "type": 1,
            "url": "qrc:/SimpleTr/SimpleTr_PageSettingsSimpleTr.qml"
        }
    ],
    "resource": "cXJlcwAAAAMAAANbAAAAGAAAArkAAAAAAAABj2ltcG9ydCBRdFF1aWNrCmltcG9ydCBWaWN0cm9uLlZlbnVzT1MKClBhZ2UgewoJaWQ6IHJvb3QKCgl0aXRsZTogIlNpbXBsZVRyIgoKCUdyYWRpZW50TGlzdFZpZXcgewoJCWlkOiBzZXR0aW5nc0xpc3RWaWV3CgoJCW1vZGVsOiBWaXNpYmxlSXRlbU1vZGVsIHsKCQkJTGlzdFN3aXRjaCB7CgkJCQkvLyUgIkJhdHRlcnkiCgkJCQl0ZXh0OiBxc1RySWQoInNpbXBsZXRyX3BhZ2Vfc2V0dGluZ3Nfc2ltcGxldHJfdGV4dF9iYXR0ZXJ5IikKCQkJCXByb3BlcnR5IGJvb2wgdmFsdWUKCQkJCWNoZWNrZWQ6IHZhbHVlCgkJCQlvbkNsaWNrZWQ6IHsKCQkJCQl2YWx1ZSA9ICFjaGVja2VkCgkJCQkJY29uc29sZS5sb2coIlN3aXRjaCBub3cgY2hlY2tlZD8iLCBjaGVja2VkKQoJCQkJfQoJCQl9CgkJfQoJfQp9CgAAAIQ8uGQYyu+clc0hHL9gob3dpwAAAAVmcl9GUkIAAAAIAGMUCQAAAABpAAAAUQMAAAAQAEIAYQB0AHQAZQByAGkAZQgAAAAABgAAACxzaW1wbGV0cl9wYWdlX3NldHRpbmdzX3NpbXBsZXRyX3RleHRfYmF0dGVyeQcAAAAAAYgAAAACAwEAAACCPLhkGMrvnJXNIRy/YKG93acAAAAFZW5fVVNCAAAACABjFAkAAAAAaQAAAE8DAAAADgBCAGEAdAB0AGUAcgB5CAAAAAAGAAAALHNpbXBsZXRyX3BhZ2Vfc2V0dGluZ3Nfc2ltcGxldHJfdGV4dF9iYXR0ZXJ5BwAAAAABiAAAAAIBAQAIAEch8gBTAGkAbQBwAGwAZQBUAHIAIQ146fwAUwBpAG0AcABsAGUAVAByAF8AUABhAGcAZQBTAGUAdAB0AGkAbgBnAHMAUwBpAG0AcABsAGUAVAByAC4AcQBtAGwADgjTFp0AUwBpAG0AcABsAGUAVAByAF8AZgByAC4AcQBtAA4I1ladAFMAaQBtAHAAbABlAFQAcgBfAGUAbgAuAHEAbQAAAAAAAgAAAAEAAAABAAAAAAAAAAAAAAAAAAIAAAADAAAAAgAAAAAAAAAAAAAAXgAAAAAAAQAAAZMAAAGYPEWP1wAAAIAAAAAAAAEAAAIbAAABmDxFj80AAAAWAAAAAAABAAAAAAAAAZg8IFUT"
}'
	}
}

