/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	readonly property int _phaseCount: 1 + Math.floor(Math.random() * 3)

	property ListModel model: ListModel {
		Component.onCompleted: {
			root._populateModel()
		}
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
			let gensetPower = 1800 + Math.floor(Math.random() * 20)
			let consumptionPower = Math.floor(Math.random() * 800)
			let randomIndex = Math.floor(Math.random() * (root._phaseCount-1))

			root.model.set(randomIndex, {
				gensetPower: gensetPower,
				consumptionPower: consumptionPower,
			})

			let totalGensetPower = 0
			let totalConsumptionPower = 0

			for (let i = 0; i < root.model.count; ++i) {
				let data = root.model.get(i)
				totalGensetPower += data.gensetPower || 0
				totalConsumptionPower += data.consumptionPower || 0
			}
			root.gensetPower = totalGensetPower
			root.consumptionPower = totalConsumptionPower
		}
	}
}
