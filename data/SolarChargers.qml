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

	property ListModel yieldHistory: ListModel {
		property real today: 0
		property real maximum: 0

		// yieldValue in kwh
		function setYield(day, yieldValue) {
			if (day < count) {
				set(day, "value", yieldValue)
			} else if (day === yieldHistory.count) {
				append({ "value": yieldValue })
			} else {
				console.warn("setYield(): bad day index", day, "model only has",
						count, "items")
				return
			}
			if (day === 0) {
				today = yieldValue
			}
		}
	}

	readonly property real power: isNaN(acPower) && isNaN(dcPower)
			? NaN
			: (isNaN(acPower) ? 0 : acPower) + (isNaN(dcPower) ? 0 : dcPower)
	property real acPower: NaN
	property real dcPower: NaN

	function addCharger(charger) {
		model.append({ solarCharger: charger })
	}

	function removeCharger(day) {
		model.remove(day)
	}

	function reset() {
		acPower = NaN
		dcPower = NaN
		model.clear()
		yieldHistory.clear()
		yieldHistory.maximum = 0
	}

	Component.onCompleted: Global.solarChargers = root
}
