/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	required property string systemServiceUid
	required property string settingsServiceUid
	required property Device chargerInputDevice

	// The first AC input, as defined by com.victronenergy.system/Ac/In/1. On "Charger only"
	// systems, if that system input is not set, then this is an input-like object providing the
	// charger details instead.
	readonly property AcInput input1: _systemInput1 ?? _chargerInput

	// The second AC input, as defined by com.victronenergy.system/Ac/In/2.
	readonly property AcInput input2: _systemInput2

	readonly property int activeInSource: _activeInSource.value ?? VenusOS.AcInputs_InputSource_NotAvailable
	readonly property string activeInServiceType: _activeInServiceType.value || ""
	readonly property real maximumAcCurrent: _maximumAcCurrent.valid ? _maximumAcCurrent.value : NaN

	readonly property AcInput highlightedInput: {
		if (_activeInSource.valid || _activeInServiceType.valid) {
			// Normally system /Ac/ActiveIn/Source provides the AC input source, and this is matched
			// against /Ac/In/<0|1>/Source to see whether AC-in 0 or AC-in 1 is the active input.
			// If that path is not set, then as a backup, try to match /Ac/ActiveIn/ServiceType
			// against /Ac/In/<0|1>/ServiceType to determine the active input.
			if (_activeInSource.valid) {
				return input1?.source === _activeInSource.value ? input1
						: input2?.source === _activeInSource.value ? input2
						: null
			} else {
				return input1?.serviceType === _activeInServiceType.value ? input1
						: input2?.serviceType === _activeInServiceType.value ? input2
						: null
			}
		} else {
			// Prefer the first Grid/Shore input, or otherwise the first operational input.
			return isGridOrShore(input1) ? input1
				: isGridOrShore(input2) ? input2
				: input1?.operational ? input1
				: input2?.operational ? input2
				: null
		}
	}

	readonly property var roles: [
		{ role: "grid", name: CommonWords.grid },
		{ role: "pvinverter", name: CommonWords.pv_inverter },
		{ role: "genset", name: CommonWords.generator },
		{ role: "acload", name: CommonWords.ac_load },
		//% "EV Charger"
		{ role: "evcharger", name: qsTrId("acInputs_evcharger") },
		//% "Heat pump"
		{ role: "heatpump", name: qsTrId("acInputs_heat_pump") },
	]

	// AC input metadata from com.victronenergy.system/Ac/In/<1|2>. There are always two inputs.
	readonly property SystemAcInputInfo systemInput1Info: SystemAcInputInfo {
		inputIndex: 0
		bindPrefix: root.systemServiceUid + "/Ac/In/" + inputIndex
		settingsServiceUid: root.settingsServiceUid
		onServiceInfoChanged: {
			const serviceUid = valid ? BackendConnection.serviceUidFromName(serviceName, deviceInstance) : ""
			_systemInput1 = root.resetInput(_systemInput1, systemInput1Info, _systemAcInputComponent, serviceUid)
		}
	}
	readonly property SystemAcInputInfo systemInput2Info: SystemAcInputInfo {
		inputIndex: 1
		bindPrefix: root.systemServiceUid + "/Ac/In/" + inputIndex
		settingsServiceUid: root.settingsServiceUid
		onServiceInfoChanged: {
			const serviceUid = valid ? BackendConnection.serviceUidFromName(serviceName, deviceInstance) : ""
			_systemInput2 = root.resetInput(_systemInput2, systemInput2Info, _systemAcInputComponent, serviceUid)
		}
	}
	// The input objects created from the system AC input data.
	property SystemAcInput _systemInput1
	property SystemAcInput _systemInput2

	// Metadata used to present charger measurements as an AC input. This is available when the
	// system has a "Charger only" configuration.
	readonly property AcInputInfo chargerInputInfo: AcInputInfo {
		readonly property VeQuickItem _systemSetup1Source: VeQuickItem {
			uid: root.settingsServiceUid + "/Settings/SystemSetup/AcInput1"
		}
		valid: !!root.chargerInputDevice
		connected: !!root.chargerInputDevice
		deviceInstance: root.chargerInputDevice?.deviceInstance ?? -1
		serviceType: root.chargerInputDevice?.serviceType ?? ""
		source: !!root.chargerInputDevice && _systemSetup1Source.valid ? _systemSetup1Source.value : VenusOS.AcInputs_InputSource_NotAvailable
	}
	onChargerInputDeviceChanged: {
		_chargerInput = root.resetInput(_chargerInput, chargerInputInfo, _chargerAcInputComponent, root.chargerInputDevice?.serviceUid ?? "")
	}
	// The input object created from the charger-only input data.
	property AcInput _chargerInput

	readonly property VeQuickItem _activeInSource: VeQuickItem {
		uid: root.systemServiceUid + "/Ac/ActiveIn/Source"
	}

	readonly property VeQuickItem _activeInServiceType: VeQuickItem {
		uid: root.systemServiceUid + "/Ac/ActiveIn/ServiceType"
	}

	readonly property VeQuickItem _maximumAcCurrent: VeQuickItem {
		uid: root.systemInput1Info.connected || root.chargerInputInfo.connected ? root.settingsServiceUid + "/Settings/Gui/Gauges/Ac/AcIn1/Consumption/Current/Max"
		   : root.systemInput2Info.connected ? root.settingsServiceUid + "/Settings/Gui/Gauges/Ac/AcIn2/Consumption/Current/Max"
		   : root.settingsServiceUid + "/Settings/Gui/Gauges/Ac/NoAcIn/Consumption/Current/Max"
	}

	readonly property Component _systemAcInputComponent: Component {
		SystemAcInput {}
	}

	readonly property Component _chargerAcInputComponent: Component {
		AcInput {
			operational: true

			// Note: normally AcInputs.qml should avoid referencing other objects in the Services
			// singleton, but these references are in a Component so they will not be loaded
			// immediately when AcInputs.qml is instantiated.
			power: Services.system.dc.charger.power
			current: Services.system.dc.charger.current
		}
	}

	property int previousActiveInSource: root.activeInSource
	onActiveInSourceChanged: {
		if (root.previousActiveInSource !== VenusOS.AcInputs_InputSource_Shore &&
			root.activeInSource === VenusOS.AcInputs_InputSource_Shore) {
			// Wake up display when shore power gets connected
			ScreenBlanker.setDisplayOn();
		}

		root.previousActiveInSource = root.activeInSource
	}

	function sourceValid(source) {
		return source !== VenusOS.AcInputs_InputSource_NotAvailable && source !== VenusOS.AcInputs_InputSource_Inverting
	}

	function findValidSource() {
		if (sourceValid(systemInput1Info.source)) {
			return systemInput1Info.source
		} else if (sourceValid(systemInput2Info.source)) {
			return systemInput2Info.source
		} else if (sourceValid(chargerInputInfo.source)) {
			return chargerInputInfo.source
		}
		return VenusOS.AcInputs_InputSource_NotAvailable
	}

	function resetInput(input, inputInfo, templateComponent, serviceUid) {
		if (input) {
			// Invalidate bindings in AcInput so that data is not fetched anymore.
			input.inputInfo = null
			input.destroy()
		}

		if (serviceUid.length > 0) {
			return templateComponent.createObject(root, { serviceUid: serviceUid, inputInfo: inputInfo })
		}
		return null
	}

	function sourceToText(source) {
		if (source === undefined) {
			return CommonWords.ac_input
		}
		switch (source) {
		case VenusOS.AcInputs_InputSource_NotAvailable:
			//% "Not available"
			return qsTrId("acInputs_not_available")
		case VenusOS.AcInputs_InputSource_Grid:
			return CommonWords.grid
		case VenusOS.AcInputs_InputSource_Generator:
			return CommonWords.generator
		case VenusOS.AcInputs_InputSource_Shore:
			//% "Shore"
			return qsTrId("acInputs_shore")
		// deliberate fall-through
		case VenusOS.AcInputs_InputSource_Inverting:
		default:
			return ""
		}
	}

	function sourceIcon(source)
	{
		switch (source) {
		case VenusOS.AcInputs_InputSource_Grid:
			return "qrc:/images/grid.svg"
		case VenusOS.AcInputs_InputSource_Generator:
			return "qrc:/images/generator.svg"
		case VenusOS.AcInputs_InputSource_Shore:
			return "qrc:/images/shore.svg"
		default:
			return ""
		}
	}

	function currentLimitTypeToText(type) {
		switch (type) {
		case VenusOS.AcInputs_InputSource_Grid:
			//% "Grid current limit"
			return qsTrId("acInputs_current_limit_grid")
		case VenusOS.AcInputs_InputSource_Generator:
			//% "Generator current limit"
			return qsTrId("acInputs_current_limit_generator")
		case VenusOS.AcInputs_InputSource_Shore:
			//% "Shore current limit"
			return qsTrId("acInputs_current_limit_shore")
		default:
			return CommonWords.input_current_limit
		}
	}

	function gensetStatusCodeToText(statusCode) {
		switch (statusCode) {
		case VenusOS.Genset_StatusCode_Standby:
			return CommonWords.standby
		case VenusOS.Genset_StatusCode_Startup1:
		case VenusOS.Genset_StatusCode_Startup2:
		case VenusOS.Genset_StatusCode_Startup3:
		case VenusOS.Genset_StatusCode_Startup4:
		case VenusOS.Genset_StatusCode_Startup5:
		case VenusOS.Genset_StatusCode_Startup6:
		case VenusOS.Genset_StatusCode_Startup7:
			return CommonWords.startup_status.arg(statusCode)
		case VenusOS.Genset_StatusCode_Running:
			return CommonWords.running_status
		case VenusOS.Genset_StatusCode_Stopping:
			//% "Stopping"
			return qsTrId("acInputs_statusCode_stopping")
		case VenusOS.Genset_StatusCode_Error:
			return CommonWords.error
		default:
			return ""
		}
	}

	function isGridOrShore(input) {
		return input
				&& (input.source === VenusOS.AcInputs_InputSource_Grid
					|| input.source === VenusOS.AcInputs_InputSource_Shore)
	}

	function roleName(role) {
		const match = roles.find(function(r) { return r.role === role })
		return match ? match.name : "--"
	}
}
