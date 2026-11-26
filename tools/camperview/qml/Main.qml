/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VeUtil
import Victron.Camper

/*
	Reads the system values over MQTT and shows them in the RV illustration.

	It reads the same values as pages/CamperPage.qml in gui-v2, but from the system service's
	totals, as this app does not have the gui-v2 data models.
*/
Window {
	id: root

	required property CamperBackend backend
	required property CamperLanguage language

	// Uids stay empty without a broker, as "mqtt/..." uids are invalid until the producer exists.
	readonly property string _settings: backend.configured ? "mqtt/settings/0/Settings/Gui" : ""

	// Values are live only while connected and the device's heartbeat arrives.
	readonly property bool _live: backend.ready && backend.heartbeatState === CamperBackend.HeartbeatActive
	readonly property string _statusText: !backend.configured
		  //% "Not configured: no MQTT broker given"
		? qsTrId("camperview_not_configured")
		: !backend.ready
		  //% "Not connected to the device"
		? qsTrId("camperview_not_connected")
		: backend.heartbeatState === CamperBackend.HeartbeatMissing
		  //% "Device not responding"
		? qsTrId("camperview_device_not_responding")
		: backend.heartbeatState === CamperBackend.HeartbeatInactive
		  //% "No data from the device"
		? qsTrId("camperview_no_data")
		: ""

	readonly property bool _systemDark: Application.styleHints.colorScheme === Qt.ColorScheme.Dark

	// The status banner, in screen px. It is not part of the illustration, so it does not scale.
	readonly property real _statusTopMargin: 16
	readonly property real _statusHorizontalPadding: 16
	readonly property real _statusVerticalPadding: 8
	readonly property real _statusFontSize: 18
	readonly property color _statusBackground: _colorScheme === 1 ? "#343A40" : "#E9ECEF"
	// Shown through the dimmed illustration while values are not live.
	readonly property color _windowColor: _colorScheme === 1 ? "black" : "white"
	readonly property real _notLiveOpacity: 0.4

	// 1 for dark, 0 for light. "default" follows the device's display settings, as gui-v2 does.
	readonly property int _colorScheme: {
		switch (backend.colorScheme) {
		case CamperBackend.ColorSchemeDark:
			return 1
		case CamperBackend.ColorSchemeLight:
			return 0
		case CamperBackend.ColorSchemeAuto:
			return _systemDark ? 1 : 0
		default:
			// RemoteConsoleColorMode 1 follows the browser; ColorScheme 0 is dark, as in Theme.
			if (Qt.platform.os === "wasm" && remoteConsoleColorModeItem.value === 1) {
				return _systemDark ? 1 : 0
			}
			return colorSchemeSettingItem.value === 0 ? 1 : 0
		}
	}

	// e.g. "com.victronenergy.battery/512" -> "mqtt/battery/512"
	readonly property string _batteryServiceUid: {
		const value = activeBatteryServiceItem.value
		if (typeof value !== "string" || value.indexOf("/") < 0) {
			return ""
		}
		const parts = value.split("/")
		return "mqtt/%1/%2".arg(parts[0].split(".").pop()).arg(parts[parts.length - 1])
	}

	// The /State of every alternator, or -1 where it is not known.
	property list<int> _alternatorStates

	function _updateAlternatorStates() {
		const states = []
		for (let i = 0; i < alternatorStateItems.count; ++i) {
			const item = alternatorStateItems.objectAt(i) as VeQuickItem
			states.push(root._int(item, -1))
		}
		_alternatorStates = states
	}

	// Inverters or Multis with trackers.
	property int _trackerDeviceCount

	function _updateTrackerDeviceCount() {
		let count = 0
		for (let i = 0; i < trackerCountItems.count; ++i) {
			const item = trackerCountItems.objectAt(i) as VeQuickItem
			if (root._int(item, 0) > 0) {
				++count
			}
		}
		_trackerDeviceCount = count
	}

	// Solar chargers, PV inverters, and inverters or Multis with trackers, as gui-v2's SolarInputs counts them.
	readonly property int _solarDeviceCount: solarChargerServices.rowCount + pvInverterServices.rowCount + _trackerDeviceCount

	function _systemUid(path) {
		return backend.configured ? "mqtt/system/0" + path : ""
	}

	function _real(item) {
		return item.valid ? Number(item.value) : NaN
	}

	function _int(item, fallback) {
		return item.valid ? parseInt(item.value) : fallback
	}

	component PhaseSum : QtObject {
		required property string prefix   // e.g. "mqtt/system/0/Ac/Consumption", or "" for none

		readonly property real power: {
			const values = [l1.value, l2.value, l3.value].filter((v) => v !== undefined && v !== null)
			return values.length ? values.reduce((sum, v) => sum + Number(v), 0) : NaN
		}
		readonly property VeQuickItem l1: VeQuickItem { uid: prefix ? prefix + "/L1/Power" : "" }
		readonly property VeQuickItem l2: VeQuickItem { uid: prefix ? prefix + "/L2/Power" : "" }
		readonly property VeQuickItem l3: VeQuickItem { uid: prefix ? prefix + "/L3/Power" : "" }
	}

	function _sum(values) {
		const valid = values.filter((v) => isFinite(v))
		return valid.length ? valid.reduce((sum, v) => sum + v, 0) : NaN
	}

	width: 1280
	height: 720
	visible: true
	//% "RV"
	title: qsTrId("camperview_title")
	color: root._windowColor

	CamperOverviewView {
		id: view

		anchors.fill: parent
		opacity: root._live ? 1 : root._notLiveOpacity

		colorScheme: root._colorScheme

		activeInputSource: root._int(activeInputSourceItem, -1)
		acInputSources: [root._int(acIn0SourceItem, -1), root._int(acIn1SourceItem, -1)]
		systemState: root._int(systemStateItem, -1)
		inverterChargerPower: root._real(inverterChargerPowerItem)
		alternatorStates: root._alternatorStates
		lowSocAlarm: root._int(lowSocAlarmItem, -1)
		veBusLowBatteryAlarm: root._int(veBusLowBatteryAlarmItem, -1)
		solarDeviceCount: root._solarDeviceCount

		activeInputPower: activeInputPowerItem.power
		generatorPower: generatorPowerItem.power
		solarPower: root._sum([root._real(dcPvPowerItem), pvOnGridItem.power, pvOnGensetItem.power, pvOnOutputItem.power])
		alternatorPower: root._real(alternatorPowerItem)
		batteryPower: root._real(batteryPowerItem)
		batterySoc: root._real(batterySocItem)
		dcLoadsPower: root._real(dcLoadsPowerItem)
		acLoadsPower: acLoadsPowerItem.power
	}

	Rectangle {
		anchors {
			top: parent.top
			topMargin: root._statusTopMargin
			horizontalCenter: parent.horizontalCenter
		}
		width: statusLabel.implicitWidth + 2 * root._statusHorizontalPadding
		height: statusLabel.implicitHeight + 2 * root._statusVerticalPadding
		radius: height / 2
		visible: root._statusText.length > 0
		color: root._statusBackground

		Text {
			id: statusLabel
			anchors.centerIn: parent
			text: root._statusText
			font.family: robotoLoader.name
			font.pixelSize: root._statusFontSize
			color: view.theme.colors.primaryText
		}
	}

	// Roboto Regular, as gui-v2 ships it, for CamperTheme's default font. There is no Medium or Bold
	// file, so those weights fall back to Regular and synthesised bold.
	FontLoader {
		id: robotoLoader
		source: "qrc:/fonts/Roboto-Regular.ttf"
	}

	VeQuickItem { id: languageItem; uid: root._settings ? root._settings + "/Language" : "" }
	// Shows the device's display language, e.g. "de". A Binding, as the language object is given
	// to the window only after its own bindings are set up.
	Binding {
		target: root.language
		property: "code"
		value: languageItem.valid ? languageItem.value : ""
	}
	VeQuickItem { id: colorSchemeSettingItem; uid: root._settings ? root._settings + "/ColorScheme" : "" }
	VeQuickItem { id: remoteConsoleColorModeItem; uid: root._settings ? root._settings + "/RemoteConsoleColorMode" : "" }

	VeQuickItem { id: activeInputSourceItem; uid: root._systemUid("/Ac/ActiveIn/Source") }
	VeQuickItem { id: acIn0SourceItem; uid: root._systemUid("/Ac/In/0/Source") }
	VeQuickItem { id: acIn1SourceItem; uid: root._systemUid("/Ac/In/1/Source") }
	VeQuickItem { id: systemStateItem; uid: root._systemUid("/SystemState/State") }
	VeQuickItem { id: inverterChargerPowerItem; uid: root._systemUid("/Dc/InverterCharger/Power") }
	VeQuickItem { id: dcPvPowerItem; uid: root._systemUid("/Dc/Pv/Power") }
	VeQuickItem { id: alternatorPowerItem; uid: root._systemUid("/Dc/Alternator/Power") }
	VeQuickItem { id: batteryPowerItem; uid: root._systemUid("/Dc/Battery/Power") }
	VeQuickItem { id: batterySocItem; uid: root._systemUid("/Dc/Battery/Soc") }
	VeQuickItem { id: dcLoadsPowerItem; uid: root._systemUid("/Dc/System/Power") }
	VeQuickItem { id: activeBatteryServiceItem; uid: root._systemUid("/ActiveBatteryService") }
	VeQuickItem { id: veBusInstanceItem; uid: root._systemUid("/VebusInstance") }

	VeQuickItem {
		id: lowSocAlarmItem
		uid: root._batteryServiceUid ? root._batteryServiceUid + "/Alarms/LowSoc" : ""
	}
	VeQuickItem {
		id: veBusLowBatteryAlarmItem
		uid: root.backend.configured && veBusInstanceItem.valid ? "mqtt/vebus/%1/Alarms/LowBattery".arg(veBusInstanceItem.value) : ""
	}

	// The services of each type, e.g. "mqtt/alternator/0". MQTT has no top-level service items, so
	// the model lists the children of "mqtt/<type>", as in components/VeQItemFilteredServiceModel.qml.
	component ServiceModel : VeQItemTableModel {
		required property list<string> serviceTypes
		uids: root.backend.configured ? serviceTypes.map((serviceType) => "mqtt/" + serviceType) : []
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	ServiceModel { id: solarChargerServices; serviceTypes: ["solarcharger"] }
	ServiceModel { id: pvInverterServices; serviceTypes: ["pvinverter"] }

	Instantiator {
		id: alternatorStateItems
		model: ServiceModel { serviceTypes: ["alternator"] }
		delegate: VeQuickItem {
			required property var model
			uid: model.uid + "/State"
			onValueChanged: Qt.callLater(root._updateAlternatorStates)
		}
		onObjectAdded: Qt.callLater(root._updateAlternatorStates)
		onObjectRemoved: Qt.callLater(root._updateAlternatorStates)
	}

	Instantiator {
		id: trackerCountItems
		model: ServiceModel { serviceTypes: ["multi", "inverter"] }
		delegate: VeQuickItem {
			required property var model
			uid: model.uid + "/NrOfTrackers"
			onValueChanged: Qt.callLater(root._updateTrackerDeviceCount)
		}
		onObjectAdded: Qt.callLater(root._updateTrackerDeviceCount)
		onObjectRemoved: Qt.callLater(root._updateTrackerDeviceCount)
	}

	PhaseSum { id: activeInputPowerItem; prefix: root._systemUid("/Ac/ActiveIn") }
	PhaseSum { id: generatorPowerItem; prefix: root._systemUid("/Ac/Genset") }
	PhaseSum { id: acLoadsPowerItem; prefix: root._systemUid("/Ac/Consumption") }
	PhaseSum { id: pvOnGridItem; prefix: root._systemUid("/Ac/PvOnGrid") }
	PhaseSum { id: pvOnGensetItem; prefix: root._systemUid("/Ac/PvOnGenset") }
	PhaseSum { id: pvOnOutputItem; prefix: root._systemUid("/Ac/PvOnOutput") }
}
