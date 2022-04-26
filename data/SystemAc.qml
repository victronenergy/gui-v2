/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import "/components/Utils.js" as Utils

QtObject {
	id: root

	property QtObject genset: QtObject {
		property real power: NaN
		onPowerChanged: Utils.updateMaximumValue("system.ac.genset.power", power)

		property ListModel phases: ListModel {}

		function resetPhases(phaseCount) {
			root._populate(phases, phaseCount)
			root._updateTotalFromPhases(root.genset, "power")
		}

		function setPhaseData(index, data) {
			phases.set(index, data)
			root._updateTotalFromPhases(root.genset, "power")
		}
	}

	property QtObject consumption: QtObject {
		property real power: NaN
		onPowerChanged: Utils.updateMaximumValue("system.ac.consumption.power", power)

		property ListModel phases: ListModel {}

		function resetPhases(phaseCount) {
			root._populate(phases, phaseCount)
			root._updateTotalFromPhases(root.consumption, "power")
		}

		function setPhaseData(index, data) {
			phases.set(index, data)
			root._updateTotalFromPhases(root.consumption, "power")
		}
	}

	function reset() {
		root.genset.phases.clear()
		root.genset.power = NaN
		root.consumption.phases.clear()
		root.consumption.power = NaN
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

	function _updateTotalFromPhases(obj, propName) {
		let total = NaN
		for (let i = 0; i < obj.phases.count; ++i) {
			if (isNaN(total)) {
				total = 0
			}
			let data = obj.phases.get(i)
			total += data[propName] || 0
		}
		obj[propName] = total
	}
}
