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

		property ListModel phases: ListModel {}
	}

	property QtObject consumption: ListModel {
		property real power

		property ListModel phases: ListModel {}
	}

	function _populate(model, count) {
		if (model.count !== count) {
			model.clear()
			for (let i = 0; i < count; ++i) {
				let data = {
					name: "L" + (i + 1),
					power: NaN
				}
				if (model === consumption.phases) {
					data = Object.assign({}, data, { "inputPower": NaN, "outputPower": NaN })
				}
				model.append(data)
			}
		}
	}

	function updateTotal(obj, propName) {
		let total = 0
		for (let i = 0; i < obj.phases.count; ++i) {
			let data = obj.phases.get(i)
			total += data[propName] || 0
		}
		obj[propName] = total
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnInput/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				root._populate(root.consumption.phases, value)
				consumptionInputObjects.model = value
			}
		}
	}

	Instantiator {
		id: consumptionInputObjects

		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/ConsumptionOnInput/L" + (index + 1) + "/Power")

			onValueChanged: {
				const inputPower = value === undefined ? 0 : value
				const outputPower = root.consumption.phases.get(model.index).outputPower
				const combinedPower = inputPower + outputPower
				root.consumption.phases.set(model.index, { "inputPower": inputPower, "power": combinedPower })
				root.updateTotal(root.consumption, "power")
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/ConsumptionOnOutput/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				root._populate(root.consumption.phases, value)
				consumptionOutputObjects.model = value
			}
		}
	}

	Instantiator {
		id: consumptionOutputObjects

		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/ConsumptionOnOutput/L" + (index + 1) + "/Power")

			onValueChanged: {
				const inputPower = root.consumption.phases.get(model.index).inputPower
				const outputPower = value === undefined ? 0 : value
				const combinedPower = inputPower + outputPower
				root.consumption.phases.set(model.index, { "outputPower": outputPower, "power": combinedPower })
				root.updateTotal(root.consumption, "power")
			}
		}
	}

	VeQuickItem {
		uid: veSystem.childUId("/Ac/Genset/NumberOfPhases")
		onValueChanged: {
			if (value !== undefined) {
				root._populate(root.genset.phases, value)
				gensetObjects.model = value
			}
		}
	}

	Instantiator {
		id: gensetObjects

		model: null
		delegate: VeQuickItem {
			uid: veDBus.childUId("/Ac/Genset/L" + (index + 1) + "/Power")

			onValueChanged: {
				const power = value === undefined ? 0 : value
				root.genset.phases.set(model.index, { "power": power })
				root.updateTotal(root.genset, "power")
			}
		}
	}
}
