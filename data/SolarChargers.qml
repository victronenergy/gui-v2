/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// Model of all solar chargers
	property ListModel model: ListModel {}

	property var yieldHistory: []

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

	function initializeYieldHistory() {
		let historyDaysAvailable = 0
		let i = 0
		for (i = 0; i < model.count; i++) {
			const charger = model.get(i).solarCharger
			if (!charger.yieldHistoriesReady) {
				return
			}
			historyDaysAvailable = Math.max(historyDaysAvailable, charger.yieldHistories.count)
		}
		if (historyDaysAvailable === 0) {
			return
		}
		var _yieldHistory = []
		for (i = 0; i < historyDaysAvailable; ++i) {
			_yieldHistory.push(_yieldHistoryForDay(i) || 0)
		}
		yieldHistory = _yieldHistory
	}

	function refreshYieldHistoryForDay(day) {
		if (yieldHistory.length === 0) {
			// not yet initialized
			return
		}

		if (day >= 0 && day < yieldHistory.length) {
			yieldHistory[day] = _yieldHistoryForDay(day)
		} else {
			console.warn("refreshYieldHistoryForDay(): invalid day:", day, "from available days:", yieldHistory.length)
		}
	}

	function _yieldHistoryForDay(day) {
		let totalYieldKwH = 0
		for (let i = 0; i < model.count; i++) {
			const charger = model.get(i).solarCharger
			const history = charger.yieldHistories.objectAt(day)
			if (history) {
				totalYieldKwH += history.yieldKwH || 0
			} else {
				console.warn("_yieldHistoryForDay(): charger", charger.serviceUid,
					"does not have history for day:", day, "total count:", charger.yieldHistories.count)
			}
		}
		return totalYieldKwH
	}

	Component.onCompleted: Global.solarChargers = root
}
