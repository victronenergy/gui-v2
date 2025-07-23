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

	readonly property VeQuickItem _enabledCustomisations: VeQuickItem {
		uid: (systemSettings && systemSettings.serviceUid.length > 0)
			? systemSettings.serviceUid + "/Gui2/EnabledCustomisations"
			: ""
		property var names: valid ? value : []

		function toggleEnabled(name) {
			var list = _enabledCustomisations.names
			if (list.indexOf(name) >= 0) {
				list.splice(list.indexOf(name))
			} else {
				list.push(name)
			}

			if (_enabledCustomisations.valid) {
				_enabledCustomisations.value = list
			} else {
				// DEBUGGING ONLY!  REMOVE THIS!
				_enabledCustomisations.names = list
			}
		}

		onNamesChanged: Customisations.enabledCustomisations = names
	}

	readonly property VeQuickItem _customisations: VeQuickItem {
		uid: (systemSettings && systemSettings.serviceUid.length > 0)
			? systemSettings.serviceUid + "/Gui2/Customisations"
			: ""
		property string json: valid ? value
			: debugJson // DEBUGGING ONLY

		property string debugJson: "[" + debug_simpleJson + "," + debug_simpleTrJson + "," + debug_devicelistJson + "]"
		property string debug_simpleJson: '
{
	"name": "SimpleExample",
	"version": "1.0",
	"minRequiredVersion": "v1.2.7",
	"maxRequiredVersion": "",
	"translations": [
		"qrc:/SimpleExample/SimpleExample_en.qm"
	],
	"integrations": [
		{
			"type": 1,
			"url": "qrc:/SimpleExample/SimpleExample_PageSettingsSimple.qml"
		}
	],
	"resource": "cXJlcwAAAAMAAAJAAAAAGAAAAaYAAAAAAAABZWltcG9ydCBRdFF1aWNrDQppbXBvcnQgVmljdHJvbi5WZW51c09TDQoNClBhZ2Ugew0KCWlkOiByb290DQoNCgl0aXRsZTogIlNpbXBsZSINCg0KCUdyYWRpZW50TGlzdFZpZXcgew0KCQlpZDogc2V0dGluZ3NMaXN0Vmlldw0KDQoJCW1vZGVsOiBWaXNpYmxlSXRlbU1vZGVsIHsNCgkJCUxpc3RTd2l0Y2ggew0KCQkJCXRleHQ6ICJTd2l0Y2giDQoJCQkJcHJvcGVydHkgYm9vbCB2YWx1ZQ0KCQkJCWNoZWNrZWQ6IHZhbHVlDQoJCQkJb25DbGlja2VkOiB7DQoJCQkJCXZhbHVlID0gIWNoZWNrZWQNCgkJCQkJY29uc29sZS5sb2coIlN3aXRjaCBub3cgY2hlY2tlZD8iLCBjaGVja2VkKQ0KCQkJCX0NCgkJCX0NCgkJfQ0KCX0NCn0NCgAAACE8uGQYyu+clc0hHL9gob3dpwAAAAVlbl9VU4gAAAACAQEADQjwo2UAUwBpAG0AcABsAGUARQB4AGEAbQBwAGwAZQAkCdgaHABTAGkAbQBwAGwAZQBFAHgAYQBtAHAAbABlAF8AUABhAGcAZQBTAGUAdAB0AGkAbgBnAHMAUwBpAG0AcABsAGUALgBxAG0AbAATCr1TnQBTAGkAbQBwAGwAZQBFAHgAYQBtAHAAbABlAF8AZQBuAC4AcQBtAAAAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAAAAgAAAAIAAAACAAAAAAAAAAAAAAAgAAAAAAABAAAAAAAAAZhfFHkQAAAAbgAAAAAAAQAAAWkAAAGYXzJpiA=="
}'
		property string debug_simpleTrJson: '
{
	"name": "SimpleTrExample",
	"version": "1.0",
	"minRequiredVersion": "v1.2.7",
	"maxRequiredVersion": "",
	"translations": [
		"qrc:/SimpleTrExample/SimpleTrExample_en.qm",
		"qrc:/SimpleTrExample/SimpleTrExample_fr.qm"
	],
	"integrations": [
		{
			"type": 1,
			"url": "qrc:/SimpleTrExample/SimpleTrExample_PageSettingsSimple.qml"
		}
	],
	"resource": "cXJlcwAAAAMAAAOxAAAAGAAAAtsAAAAAAAABq2ltcG9ydCBRdFF1aWNrDQppbXBvcnQgVmljdHJvbi5WZW51c09TDQoNClBhZ2Ugew0KCWlkOiByb290DQoNCgl0aXRsZTogIlNpbXBsZVRyIg0KDQoJR3JhZGllbnRMaXN0VmlldyB7DQoJCWlkOiBzZXR0aW5nc0xpc3RWaWV3DQoNCgkJbW9kZWw6IFZpc2libGVJdGVtTW9kZWwgew0KCQkJTGlzdFN3aXRjaCB7DQoJCQkJLy8lICJCYXR0ZXJ5Ig0KCQkJCXRleHQ6IHFzVHJJZCgic2ltcGxldHJleGFtcGxlX3BhZ2VzZXR0aW5nc3NpbXBsZV90ZXh0X2JhdHRlcnkiKQ0KCQkJCXByb3BlcnR5IGJvb2wgdmFsdWUNCgkJCQljaGVja2VkOiB2YWx1ZQ0KCQkJCW9uQ2xpY2tlZDogew0KCQkJCQl2YWx1ZSA9ICFjaGVja2VkDQoJCQkJCWNvbnNvbGUubG9nKCJTd2l0Y2ggbm93IGNoZWNrZWQ/IiwgY2hlY2tlZCkNCgkJCQl9DQoJCQl9DQoJCX0NCgl9DQp9DQoAAACFPLhkGMrvnJXNIRy/YKG93acAAAAFZW5fVVNCAAAACAzIHIkAAAAAaQAAAFIDAAAADgBCAGEAdAB0AGUAcgB5CAAAAAAGAAAAL3NpbXBsZXRyZXhhbXBsZV9wYWdlc2V0dGluZ3NzaW1wbGVfdGV4dF9iYXR0ZXJ5BwAAAAABiAAAAAIBAQAAAIc8uGQYyu+clc0hHL9gob3dpwAAAAVmcl9GUkIAAAAIDMgciQAAAABpAAAAVAMAAAAQAEIAYQB0AHQAZQByAGkAZQgAAAAABgAAAC9zaW1wbGV0cmV4YW1wbGVfcGFnZXNldHRpbmdzc2ltcGxlX3RleHRfYmF0dGVyeQcAAAAAAYgAAAACAwEADwQEeeUAUwBpAG0AcABsAGUAVAByAEUAeABhAG0AcABsAGUAJgUkxZwAUwBpAG0AcABsAGUAVAByAEUAeABhAG0AcABsAGUAXwBQAGEAZwBlAFMAZQB0AHQAaQBuAGcAcwBTAGkAbQBwAGwAZQAuAHEAbQBsABUDVOa9AFMAaQBtAHAAbABlAFQAcgBFAHgAYQBtAHAAbABlAF8AZQBuAC4AcQBtABUDVaa9AFMAaQBtAHAAbABlAFQAcgBFAHgAYQBtAHAAbABlAF8AZgByAC4AcQBtAAAAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAAAAgAAAAMAAAACAAAAAAAAAAAAAAB2AAAAAAABAAABrwAAAZhfM8VoAAAApgAAAAAAAQAAAjgAAAGYXzPFaAAAACQAAAAAAAEAAAAAAAABmF8VBbA="
}'
property string debug_devicelistJson: '
{
	"name": "DeviceListExample",
	"version": "1.0",
	"minRequiredVersion": "v1.2.7",
	"maxRequiredVersion": "",
	"translations": [
		"qrc:/DeviceListExample/DeviceListExample_en.qm",
		"qrc:/DeviceListExample/DeviceListExample_fr.qm"
	],
	"integrations": [
		{
			"type": 2,
			"productId": "0x106",
			"url": "qrc:/DeviceListExample/DeviceListExample_CellVoltages.qml",
			"title": "devicelistexample_cellvoltages_title_cell_voltages"
		},
		{
			"type": 2,
			"productId": "0x106",
			"url": "qrc:/DeviceListExample/DeviceListExample_CellTemperatures.qml",
			"title": "Cell Temperatures"
		},
		{
			"type": 2,
			"productId": "0x106",
			"url": "qrc:/DeviceListExample/DeviceListExample_ComponentError.qml",
			"title": "Invalid Customisation"
		}
	],
	"resource": "cXJlcwAAAAMAAAgyAAAAGAAABrgAAAAAAAAB72ltcG9ydCBRdFF1aWNrDQppbXBvcnQgVmljdHJvbi5WZW51c09TDQoNClBhZ2Ugew0KCWlkOiByb290DQoNCgkvLyUgIkNlbGwgVm9sdGFnZXMiDQoJdGl0bGU6IHFzVHJJZCgiZGV2aWNlbGlzdGV4YW1wbGVfY2VsbHZvbHRhZ2VzX3RpdGxlX2NlbGxfdm9sdGFnZXMiKQ0KDQoJR3JhZGllbnRMaXN0VmlldyB7DQoJCWlkOiBzZXR0aW5nc0xpc3RWaWV3DQoNCgkJbW9kZWw6IFZpc2libGVJdGVtTW9kZWwgew0KCQkJTGlzdFN3aXRjaCB7DQoJCQkJLy8lICJCYXR0ZXJ5Ig0KCQkJCXRleHQ6IHFzVHJJZCgiZGV2aWNlbGlzdGV4YW1wbGVfY2VsbHZvbHRhZ2VzX3RleHRfYmF0dGVyeSIpDQoJCQkJcHJvcGVydHkgYm9vbCB2YWx1ZQ0KCQkJCWNoZWNrZWQ6IHZhbHVlDQoJCQkJb25DbGlja2VkOiB7DQoJCQkJCXZhbHVlID0gIWNoZWNrZWQNCgkJCQkJY29uc29sZS5sb2coIlN3aXRjaCBub3cgY2hlY2tlZD8iLCBjaGVja2VkKQ0KCQkJCX0NCgkJCX0NCgkJfQ0KCX0NCn0NCgAAAOw8uGQYyu+clc0hHL9gob3dpwAAAAVmcl9GUkIAAAAQCppKcwAAAFALxDVpAAAAAGkAAACxAwAAABAAQgBhAHQAdABlAHIAaQBlCAAAAAAGAAAAK2RldmljZWxpc3RleGFtcGxlX2NlbGx2b2x0YWdlc190ZXh0X2JhdHRlcnkHAAAAAAEDAAAAGgBDAGUAbABsACAAVgBvAGwAdABhAGcAZQBzCAAAAAAGAAAAMmRldmljZWxpc3RleGFtcGxlX2NlbGx2b2x0YWdlc190aXRsZV9jZWxsX3ZvbHRhZ2VzBwAAAAABiAAAAAIDAQAAActpbXBvcnQgUXRRdWljaw0KaW1wb3J0IFZpY3Ryb24uVmVudXNPUw0KDQpQYWdlIHsNCglpZDogcm9vdA0KDQoJdGl0bGU6ICJDZWxsIFRlbXBlcmF0dXJlcyIgLy8gTm8gdHJhbnNsYXRpb24sIGp1c3QgYXMgYW4gZXhhbXBsZS4NCg0KCUdyYWRpZW50TGlzdFZpZXcgew0KCQlpZDogc2V0dGluZ3NMaXN0Vmlldw0KDQoJCW1vZGVsOiBWaXNpYmxlSXRlbU1vZGVsIHsNCgkJCUxpc3RTd2l0Y2ggew0KCQkJCXRleHQ6ICJUZW1wZXJhdHVyZXMiIC8vIEFnYWluLCBubyB0cmFuc2xhdGlvbiwganVzdCBhcyBhbiBleGFtcGxlLg0KCQkJCXByb3BlcnR5IGJvb2wgdmFsdWUNCgkJCQljaGVja2VkOiB2YWx1ZQ0KCQkJCW9uQ2xpY2tlZDogew0KCQkJCQl2YWx1ZSA9ICFjaGVja2VkDQoJCQkJCWNvbnNvbGUubG9nKCJTd2l0Y2ggbm93IGNoZWNrZWQ/IiwgY2hlY2tlZCkNCgkJCQl9DQoJCQl9DQoJCX0NCgl9DQp9DQoAAADqPLhkGMrvnJXNIRy/YKG93acAAAAFZW5fVVNCAAAAEAqaSnMAAABOC8Q1aQAAAABpAAAArwMAAAAOAEIAYQB0AHQAZQByAHkIAAAAAAYAAAArZGV2aWNlbGlzdGV4YW1wbGVfY2VsbHZvbHRhZ2VzX3RleHRfYmF0dGVyeQcAAAAAAQMAAAAaAEMAZQBsAGwAIABWAG8AbAB0AGEAZwBlAHMIAAAAAAYAAAAyZGV2aWNlbGlzdGV4YW1wbGVfY2VsbHZvbHRhZ2VzX3RpdGxlX2NlbGxfdm9sdGFnZXMHAAAAAAGIAAAAAgEBAAAA/GltcG9ydCBRdFF1aWNrDQppbXBvcnQgVmljdHJvbi5WZW51c09TDQoNClBhZ2Ugew0KCWlkOiByb290DQoNCgl0aXRsZTogIkN1c3RvbWlzYXRpb24gV2l0aCBFcnJvcnMiIC8vIE5vIHRyYW5zbGF0aW9uLCBqdXN0IGFzIGFuIGV4YW1wbGUuDQoNCglJbnZhbGlkQ3VzdG9taXNhdGlvbiB7DQoJCXRoaXMgd2lsbCBub3QgY29tcGlsZSB1c2luZyBRUW1sQ29tcG9uZW50DQoJCWJ1dCBpdCBzaG91bGQgbm90IGJyZWFrIGd1aS12Mg0KCX0NCn0NCgARDo1hxQBEAGUAdgBpAGMAZQBMAGkAcwB0AEUAeABhAG0AcABsAGUAIgvixPwARABlAHYAaQBjAGUATABpAHMAdABFAHgAYQBtAHAAbABlAF8AQwBlAGwAbABWAG8AbAB0AGEAZwBlAHMALgBxAG0AbAAXBkeW3QBEAGUAdgBpAGMAZQBMAGkAcwB0AEUAeABhAG0AcABsAGUAXwBmAHIALgBxAG0AJgV6g3wARABlAHYAaQBjAGUATABpAHMAdABFAHgAYQBtAHAAbABlAF8AQwBlAGwAbABUAGUAbQBwAGUAcgBhAHQAdQByAGUAcwAuAHEAbQBsABcGQtbdAEQAZQB2AGkAYwBlAEwAaQBzAHQARQB4AGEAbQBwAGwAZQBfAGUAbgAuAHEAbQAkCce7nABEAGUAdgBpAGMAZQBMAGkAcwB0AEUAeABhAG0AcABsAGUAXwBDAG8AbQBwAG8AbgBlAG4AdABFAHIAcgBvAHIALgBxAG0AbAAAAAAAAgAAAAEAAAABAAAAAAAAAAAAAAAAAAIAAAAFAAAAAgAAAAAAAAAAAAAApgAAAAAAAQAAAuMAAAGYXxR5EAAAAPgAAAAAAAEAAASyAAABmF8vc3gAAAByAAAAAAABAAAB8wAAAZhfL3N4AAABLAAAAAAAAQAABaAAAAGYXyEPuAAAACgAAAAAAAEAAAAAAAABmF8UeRA="
}'
	}
}

