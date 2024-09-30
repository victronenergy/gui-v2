/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property ActiveAcInput activeInput
	readonly property ActiveAcInput generatorInput: activeInput && activeInput.source === VenusOS.AcInputs_InputSource_Generator ? activeInput : null

	readonly property AcInputSystemInfo activeInputInfo: input1Info.isActiveInput ? input1Info
			: input2Info.isActiveInput ? input2Info
			: null

	property real power: activeInput != null ? activeInput.power : NaN
	property real current: activeInput != null ? activeInput.current : NaN

	readonly property var roles: [
		{ role: "grid", name: CommonWords.grid },
		{ role: "pvinverter", name: CommonWords.pv_inverter },
		{ role: "genset", name: CommonWords.generator },
		{ role: "acload", name: CommonWords.ac_load },
	]

	// AC input metadata from com.victronenergy.system/Ac/In/<1|2>. There are always two inputs.
	property AcInputSystemInfo input1Info: AcInputSystemInfo {
		inputIndex: 0
		isActiveInput: valid && source === _activeInputSource.sourceAsInt
	}
	property AcInputSystemInfo input2Info: AcInputSystemInfo {
		inputIndex: 1
		isActiveInput: valid && source === _activeInputSource.sourceAsInt
	}

	readonly property VeQuickItem _activeInputSource: VeQuickItem {
		readonly property int sourceAsInt: !isValid ? VenusOS.AcInputs_InputSource_NotAvailable : parseInt(value)
		uid: Global.system.serviceUid + "/Ac/ActiveIn/Source"
	}

	readonly property Component _activeAcInputComponent: Component {
		ActiveAcInput {}
	}

	// Set activeInput to a valid object when /Ac/ActiveIn/Source is set to a valid source and
	// triggers input1Info or input2Info to become the active input.
	onActiveInputInfoChanged: {
		if (activeInput) {
			activeInput.destroy()
			activeInput = null
		}
		if (activeInputInfo) {
			const serviceUid = BackendConnection.type === BackendConnection.MqttSource
				  // this looks like: 'mqtt/vebus/289/'
				? "mqtt/" + activeInputInfo.serviceType + "/" + activeInputInfo.deviceInstance
				  // this looks like: "dbus/com.victronenergy.vebus.ttyO1"
				: BackendConnection.uidPrefix() + "/" + activeInputInfo.serviceName
			activeInput = _activeAcInputComponent.createObject(root, { serviceUid: serviceUid, inputInfo: activeInputInfo })
		}
	}

	function sourceValid(source) {
		return source !== VenusOS.AcInputs_InputSource_NotAvailable && source !== VenusOS.AcInputs_InputSource_Inverting
	}

	function findValidSource() {
		if (activeInput) {
			return activeInput.source
		} else if (sourceValid(input1Info.source)) {
			return input1Info.source
		} else if (sourceValid(input2Info.source)) {
			return input2Info.source
		}
		return VenusOS.AcInputs_InputSource_NotAvailable
	}

	function sourceToText(source) {
		if (source === undefined) {
			return CommonWords.acInput()
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

	function roleName(role) {
		const match = roles.find(function(r) { return r.role === role })
		return match ? match.name : "--"
	}

	Component.onCompleted: Global.acInputs = root
}
