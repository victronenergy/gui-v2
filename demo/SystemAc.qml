/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property QtObject genset: QtObject {
		property real power

		property ListModel phases: ListModel {
			Component.onCompleted: root._populate(genset.phases)
		}
	}

	property QtObject consumption: ListModel {
		property real power

		property ListModel phases: ListModel {
			Component.onCompleted: root._populate(consumption.phases)
		}
	}

	readonly property int _phaseCount: 1 + Math.floor(Math.random() * 3)

	function _populate(model) {
		model.clear()
		for (let i = 0; i < _phaseCount; ++i) {
			model.append({
				name: "L" + (i + 1),
				power: NaN
			})
		}
	}

	function _updateTotal(obj) {
		let totalPower = 0
		for (let i = 0; i < obj.phases.count; ++i) {
			let data = obj.phases.get(i)
			totalPower += data.power || 0
		}
		obj.power = totalPower
	}

	property Timer demoTimer: Timer {
		running: true
		interval: 2000
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			let randomIndex = Math.floor(Math.random() * root._phaseCount)
			genset.phases.set(randomIndex, {
				power: 1800 + Math.floor(Math.random() * 20)
			})

			// For consumption, add some wild fluctuations that can be seen in the Brief side panel graph
			consumption.phases.set(randomIndex, {
				power: Math.floor(Math.random() * 800),
			})

			root._updateTotal(genset)
			root._updateTotal(consumption)
		}
	}
}
