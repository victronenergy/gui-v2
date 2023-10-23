/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property var connectedInput // Only one AC input can be connected and active at any time.
	property var generatorInput

	property real power: connectedInput != null ? connectedInput.power : NaN
	property real current: connectedInput != null ? connectedInput.current : NaN
	property real currentLimit: connectedInput != null ? connectedInput.currentLimit : NaN

	property DeviceModel model: DeviceModel {
		modelId: "acInputs"
	}

	function addInput(input) {
		model.addDevice(input)
	}

	function removeInput(input) {
		if (model.removeDevice(input.serviceUid)) {
			if (input === connectedInput) {
				connectedInput = null
			}
			if (input === generatorInput) {
				generatorInput = null
			}
		}
	}

	function reset() {
		model.clear()
		connectedInput = null
		generatorInput = null
	}

	function currentLimitTypeToText(type) {
		switch (type) {
		case VenusOS.AcInputs_InputType_Grid:
			//% "Grid current limit"
			return qsTrId("acInputs_current_limit_grid")
		case VenusOS.AcInputs_InputType_Generator:
			//% "Generator current limit"
			return qsTrId("acInputs_current_limit_generator")
		case VenusOS.AcInputs_InputType_Shore:
			//% "Shore current limit"
			return qsTrId("acInputs_current_limit_shore")
		default:
			return ""
		}
	}

	function gensetStatusCodeToText(statusCode) {
		switch (statusCode) {
		case VenusOS.Genset_StatusCode_Startup0:
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

	Component.onCompleted: Global.acInputs = root
}
