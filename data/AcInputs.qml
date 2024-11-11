/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property AcInput input1
	property AcInput input2

	// When the UI has to choose to show a single AC input (e.g. for Brief AC-in gauge), prefer the
	// first Grid/Shore input that is operational, or otherwise, any operational input.
	readonly property AcInput highlightedInput: _highlightInput(input1) ? input1
			: _highlightInput(input2) ? input2
			: input1?.operational ? input1
			: input2?.operational ? input2
			: null

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
	property AcInputSystemInfo input1Info: AcInputSystemInfo {
		inputIndex: 0
		onServiceInfoChanged: input1 = root.resetInput(input1, input1Info)
	}
	property AcInputSystemInfo input2Info: AcInputSystemInfo {
		inputIndex: 1
		onServiceInfoChanged: input2 = root.resetInput(input2, input2Info)
	}

	readonly property Component _acInputComponent: Component {
		AcInput {}
	}

	function sourceValid(source) {
		return source !== VenusOS.AcInputs_InputSource_NotAvailable && source !== VenusOS.AcInputs_InputSource_Inverting
	}

	function findValidSource() {
		if (sourceValid(input1Info.source)) {
			return input1Info.source
		} else if (sourceValid(input2Info.source)) {
			return input2Info.source
		}
		return VenusOS.AcInputs_InputSource_NotAvailable
	}

	function resetInput(input, inputInfo) {
		if (input) {
			// Invalidate bindings in AcInput so that data is not fetched anymore.
			input.inputInfo = null
			input.destroy()
		}

		if (inputInfo.valid) {
			const serviceUid = BackendConnection.serviceUidFromName(inputInfo.serviceName, inputInfo.deviceInstance)
			return _acInputComponent.createObject(root, { serviceUid: serviceUid, inputInfo: inputInfo })
		}
		return null
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

	function _highlightInput(input) {
		return input
				&& input.operational
				&& (input.inputInfo.source === VenusOS.AcInputs_InputSource_Grid
					|| input.inputInfo.source === VenusOS.AcInputs_InputSource_Shore)
	}

	Component.onCompleted: Global.acInputs = root
}
