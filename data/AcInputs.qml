/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	readonly property ActiveAcInput activeInput: _activeInputLoader.item
	readonly property ActiveAcInput generatorInput: activeInput && activeInput.source === VenusOS.AcInputs_InputSource_Generator ? activeInput : null

	// TODO remove this
	readonly property ActiveAcInput connectedInput: activeInput

	property real power: activeInput != null ? activeInput.power : NaN
	property real current: activeInput != null ? activeInput.current : NaN
	property real currentLimit: activeInput != null ? activeInput.currentLimit : NaN

	readonly property var roles: [
		{ role: "grid", name: CommonWords.grid_meter },
		{ role: "pvinverter", name: CommonWords.pv_inverter },
		{ role: "genset", name: CommonWords.generator },
		{ role: "acload", name: CommonWords.ac_load },
	]

	// Set activeInput to a valid object when /Ac/ActiveIn/Source is set to a valid source.
	readonly property VeQuickItem _activeInputSource: VeQuickItem {
		readonly property int sourceAsInt: value === undefined ? VenusOS.AcInputs_InputSource_NotAvailable : parseInt(value)

		uid: Global.system.serviceUid + "/Ac/ActiveIn/Source"
	}
	readonly property Loader _activeInputLoader: Loader {
		active: root._activeInputSource.sourceAsInt !== VenusOS.AcInputs_InputSource_NotAvailable
				&& root._activeInputSource.sourceAsInt !== VenusOS.AcInputs_InputSource_Inverting
		sourceComponent: ActiveAcInput {
			source: root._activeInputSource.sourceAsInt
		}
	}

	function sourceToText(source) {
		switch (source) {
		case VenusOS.AcInputs_InputSource_Grid:
			return CommonWords.grid_meter
		case VenusOS.AcInputs_InputSource_Generator:
			return CommonWords.generator
		case VenusOS.AcInputs_InputSource_Shore:
			//% "Shore"
			return qsTrId("acInputs_shore")
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
			console.warn("Unrecognized AC Input Type")
			//% "Unrecognized current limit"
			return qsTrId("acInputs_current_limit_unrecognized")
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

	function roleName(role) {
		const match = roles.find(function(r) { return r.role === role })
		return match ? match.name : "--"
	}

	Component.onCompleted: Global.acInputs = root
}
