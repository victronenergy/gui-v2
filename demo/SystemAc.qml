/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: {
			let phaseCount = 1 + Math.floor(Math.random() * 3)
			root._populateModel(phaseCount)
		}
	}

	property QtObject genset: QtObject {
		property real power

		onPowerChanged: Utils.updateMaximumValue("systemAc.genset.power", power)
	}

	property QtObject consumption: QtObject {
		readonly property real power: powerOnInput + powerOnOutput
		property real powerOnInput
		property real powerOnOutput
	}

	function _populateModel(phaseCount) {
		model.clear()
		for (let i = 0; i < phaseCount; ++i) {
			model.append({
				phaseId: "L" + (i + 1),
				gensetPower: 0,
				consumptionPowerOnInput: 0,
				consumptionPowerOnOutput: 0,
			})
		}
	}

	Timer {
		running: true
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			// For consumption, add some wild fluctuations that can be seen in the Brief side panel graph
			let genset = 1800 + Math.floor(Math.random() * 20)
			let inputConsumption = Math.floor(Math.random() * 800)
			let outputConsumption = Math.floor(Math.random() * 10)
			let randomIndex = Math.floor(Math.random() * root.model.count)

			root.model.set(randomIndex, {
				gensetPower: genset,
				consumptionPowerOnInput: inputConsumption,
				consumptionPowerOnOutput: outputConsumption,
			})

			let totalGenset = 0
			let totalInputConsumption = 0
			let totalOutputConsumption = 0

			for (let i = 0; i < root.model.count; ++i) {
				let data = root.model.get(i)
				totalGenset += data.gensetPower
				totalInputConsumption += data.consumptionPowerOnInput
				totalOutputConsumption += data.consumptionPowerOnOutput
			}
			root.genset.power = totalGenset
			root.consumption.powerOnInput = totalInputConsumption
			root.consumption.powerOnOutput = totalOutputConsumption
		}
	}
}
