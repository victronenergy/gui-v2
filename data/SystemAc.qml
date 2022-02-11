/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: root._populateModel()
	}

	property real gensetPower
	property real consumptionPower

	function _populateModel() {
		model.clear()
		for (let i = 0; i < 3; ++i) {
			model.append({
				name: "L" + (i + 1),
				gensetPower: NaN,
				consumptionPower: NaN,
				consumptionPowerOnInput: NaN,
				consumptionPowerOnOutput: NaN,
			})
		}
	}

	function _updateConsumptionTotal(phaseIndex, prop, value) {
		model.setProperty(phaseIndex, prop, value)
		let data = model.get(phaseIndex)
		let total = (data.consumptionPowerOnInput || 0) + (data.consumptionPowerOnOutput || 0)
		model.setProperty(phaseIndex, "consumptionPower", total)
		_updateTotal("consumptionPower")
	}

	function _updateTotal(prop) {
		let total = 0
		for (let i = 0; i < model.count; ++i) {
			let v = model.get(i)[prop]
			if (!isNaN(v)) {
				total += v
			}
		}
		root[prop] = total
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnInput/NumberOfPhases")
		onValueChanged: { if (value !== undefined) consumptionInputObjects.model = value }
	}

	Instantiator {
		id: consumptionInputObjects

		model: null
		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/ConsumptionOnInput/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root._updateConsumptionTotal(model.index, "consumptionPowerOnInput", power)
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnOutput/NumberOfPhases")
		onValueChanged: { if (value !== undefined) consumptionOutputObjects.model = value }
	}

	Instantiator {
		id: consumptionOutputObjects

		model: null
		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/ConsumptionOnOutput/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root._updateConsumptionTotal(model.index, "consumptionPowerOnOutput", power)
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/Genset/NumberOfPhases")
		onValueChanged: { if (value !== undefined) gensetObjects.model = value }
	}

	Instantiator {
		id: gensetObjects

		model: null
		delegate: VeQuickItem {
			readonly property string phaseId: "L" + (index + 1)
			property real power

			uid: veDBus.childUId("/Ac/Genset/" + phaseId + "/Power")
			onValueChanged: {
				power = value === undefined ? 0 : value
				root.model.setProperty(model.index, "gensetPower", power)
				root._updateTotal("gensetPower")
			}
		}
	}
}
