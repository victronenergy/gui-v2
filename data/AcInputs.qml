/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property var connectedInput // Only one AC input can be connected and active at any time.
	property var generatorInput

	property real power: connectedInput != null ? connectedInput.power : NaN
	property real current: connectedInput != null ? connectedInput.current : NaN

	property ListModel model: ListModel {}

	function addInput(input) {
		model.append({ input: input })
	}

	function removeInput(index) {
		if (index < 0 || index >= model.count) {
			console.warn("removeInput(): bad index", index)
			return
		}
		const input = get(index).input
		if (input === connectedInput) {
			connectedInput = null
		}
		if (input === generatorInput) {
			generatorInput = null
		}
		model.remove(index)
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
			return qsTrId("inverter_current_limit_grid")
		case VenusOS.AcInputs_InputType_Generator:
			//% "Generator current limit"
			return qsTrId("inverter_current_limit_generator")
		case VenusOS.AcInputs_InputType_Shore:
			//% "Shore current limit"
			return qsTrId("inverter_current_limit_shore")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.acInputs = root
}
