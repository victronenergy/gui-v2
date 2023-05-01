/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListModel {
	id: root

	property var targetSolarCharger   // unset if wanting total yield for all chargers
	property var dayRange: [0, 1]
	property real maximumYield

	property bool _resetting

	property Instantiator _yieldUpdateConnections: Instantiator {
		model: Global.solarChargers.model

		delegate: Connections {
			target: model.solarCharger
			enabled: !root._resetting

			function onYieldUpdatedForDay(day, yieldKwh) {
				if (!root._resetting) {
					if (day >= root.dayRange[0] && day < root.dayRange[1]
							&& (!root.targetSolarCharger || root.targetSolarCharger === target)) {
						root._refreshYieldForDay(day)
					}
				}
			}
		}
	}

	function _refreshYieldForDay(day) {
		// Get the total yield for this day across all chargers (or just the target charger, if set)
		let i = 0
		let yieldForDay = 0
		for (i = 0; i < Global.solarChargers.model.count; ++i) {
			const solarCharger = Global.solarChargers.model.get(i).solarCharger
			if (!targetSolarCharger || solarCharger === targetSolarCharger) {
				const history = solarCharger.dailyHistory(day)
				if (history) {
					if (!isNaN(history.yieldKwh)) {
						yieldForDay += history.yieldKwh
					}
				}
			}
		}
		maximumYield = Math.max(maximumYield, yieldForDay)
		const insertionIndex = day - dayRange[0] // If first day is > 0, need to offset the index
		if (insertionIndex === count) {
			append({ "yieldKwh": yieldForDay })
		} else if (insertionIndex < count) {
			setProperty(insertionIndex, "yieldKwh", yieldForDay)
		} else {
			console.warn("Cannot refresh solar yield, have", count, "items but asked to refresh day",
					day, "for range", dayRange)
		}
	}

	function _reset() {
		_resetting = true
		maximumYield = 0
		clear()
		for (let day = dayRange[0]; day < dayRange[1]; ++day) {
			_refreshYieldForDay(day)
		}
		_resetting = false
	}

	onDayRangeChanged: Qt.callLater(_reset)
	onTargetSolarChargerChanged: Qt.callLater(_reset)
}
