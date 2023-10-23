/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

QtObject {
	id: root

	property real power: NaN
	property real current: NaN

	property DeviceModel model: DeviceModel {
		modelId: "dcInputs"
	}

	function addInput(input) {
		if (model.addDevice(input)) {
			updateTotals()
		}
	}

	function removeInput(input) {
		if (model.removeDevice(input.serviceUid)) {
			updateTotals()
		}
	}

	function updateTotals() {
		let totalPower = NaN
		let totalCurrent = NaN
		for (let i = 0; i < model.count; ++i) {
			const input = model.deviceAt(i)
			const p = input.power
			if (!isNaN(p)) {
				if (isNaN(totalPower)) {
					totalPower = 0
				}
				totalPower += p
			}
			const c = input.current
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
