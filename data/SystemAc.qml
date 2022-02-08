/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property QtObject genset: QtObject {
		property real power
	}

	property QtObject consumption: QtObject {
		readonly property real power: powerOnInput + powerOnOutput
		property real powerOnInput
		property real powerOnOutput
	}

	function _updateTotal(value, instantiator, instantiatorDelegateProp, obj, objProp) {
		if (value !== undefined) {
			let total = 0
			for (let i = 0; i < instantiator.count; ++i) {
				total += instantiator.objectAt(i)[instantiatorDelegateProp]
			}
			obj[objProp] = total
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnInput/NumberOfPhases")
		onValueChanged: { if (value !== undefined) consumptionInputObjects.model = value }
	}

	Instantiator {
		id: consumptionInputObjects

		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/ConsumptionOnInput/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root._updateTotal(value, consumptionInputObjects, "power", root.consumption, "powerOnInput")
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnOutput/NumberOfPhases")
		onValueChanged: { if (value !== undefined) consumptionOutputObjects.model = value }
	}

	Instantiator {
		id: consumptionOutputObjects

		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/ConsumptionOnOutput/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root._updateTotal(value, consumptionOutputObjects, "power", root.consumption, "powerOnOutput")
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/Genset/NumberOfPhases")
		onValueChanged: { if (value !== undefined) gensetObjects.model = value }
	}

	Instantiator {
		id: gensetObjects

		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/Genset/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root._updateTotal(value, gensetObjects, "power", root.genset, "power")
			}
		}
	}
}
