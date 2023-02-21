/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property real power: NaN
	property real current: NaN

	property ListModel model: ListModel {}

	function addInput(input) {
		model.append({ input: input })
		updateTotals()
	}

	function insertInput(index, input) {
		model.insert(index >= 0 && index < model.count ? index : model.count, { input: input })
	}

	function removeInput(index) {
		model.remove(index)
		updateTotals()
	}

	function updateTotals() {
		let totalPower = NaN
		let totalCurrent = NaN
		for (let i = 0; i < model.count; ++i) {
			const p = model.get(i).input.power
			if (!isNaN(p)) {
				if (isNaN(totalPower)) {
					totalPower = 0
				}
				totalPower += p
			}
			const c = model.get(i).input.current
			if (!isNaN(c)) {
				if (isNaN(totalCurrent)) {
					totalCurrent = 0
				}
				totalCurrent += c
			}
		}
		power = totalPower
		current = totalCurrent
	}

	function reset() {
		model.clear()
		power = NaN
		current = NaN
	}

	Component.onCompleted: Global.dcInputs = root
}
