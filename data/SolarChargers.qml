/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	// Model of all solar chargers
	property ListModel model: ListModel {}

	property var yieldHistory: []

	function updateYieldHistory(day, yieldValueKwh) {
		if (day < yieldHistory.length) {
			yieldHistory[day] = yieldValueKwh
		} else if (day === yieldHistory.length) {
			yieldHistory.push(yieldValueKwh)
		} else {
			console.warn("setYield(): bad day index", day, "model only has",
					yieldHistory.length, "items")
			return
		}
	}

	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	property real dcPower: NaN

	// Unlike for power, the AC and DC currents cannot be combined because amps for AC and DC
	// sources are on different scales. So if they are both present, the total is NaN.
	readonly property real current: (acCurrent || 0) !== 0 && (dcCurrent || 0) !== 0
			? NaN
			: (acCurrent || 0) === 0 ? dcCurrent : acCurrent
	property real acCurrent: NaN
	property real dcCurrent: NaN

	function addCharger(charger) {
		model.append({ solarCharger: charger })
	}

	function removeCharger(day) {
		model.remove(day)
	}

	function reset() {
		acPower = NaN
		dcPower = NaN
		acCurrent = NaN
		dcCurrent = NaN
		model.clear()
		yieldHistory = []
	}

	Component.onCompleted: Global.solarChargers = root
}
