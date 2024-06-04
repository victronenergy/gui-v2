/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string bindPrefix
	property string deviceName
	property int trackerCount

	property SolarHistoryErrorModel errorModel: SolarHistoryErrorModel {
		uidPrefix: root.bindPrefix + "/History/Overall"
	}

	signal yieldUpdatedForDay(day: int, yieldKwh: real)

	function dailyHistory(day) {
		return _historyObjects.dailyHistory(day)
	}

	function dailyTrackerHistory(day, trackerIndex) {
		return _historyObjects.dailyTrackerHistory(day, trackerIndex)
	}

	function trackerName(trackerIndex) {
		const nameObject = _trackerNames.objectAt(trackerIndex)
		const name = nameObject ? nameObject.value || "" : ""
		return name ? name : Global.solarChargers.defaultTrackerName(trackerIndex, trackerCount, deviceName)
	}

	readonly property Instantiator _trackerNames: Instantiator {
		model: root.trackerCount
		delegate: VeQuickItem {
			uid: root.bindPrefix + "/Pv/" + model.index + "/Name"
		}
	}

	readonly property Instantiator _historyObjects: Instantiator {
		function dailyHistory(day) {
			return objectAt(day)
		}

		function dailyTrackerHistory(day, trackerIndex) {
			let overallDailyHistory = objectAt(day)
			if (!overallDailyHistory) {
				// History is not yet available for this day
				return null
			}
			return overallDailyHistory.trackerHistoryObjects.objectAt(trackerIndex)
		}

		model: undefined    // ensure delegates are not created before history model is set

		// The overall history for this day, for this charger (i.e. data includes all trackers).
		delegate: SolarDailyHistory {
			id: overallDailyHistoryDelegate

			// If there is more than one tracker, find the daily histories for each tracker, under
			// com.victronenergy.root.tty0/History/Daily/<day>/Pv/<pv-index>
			readonly property Instantiator trackerHistoryObjects: Instantiator {
				model: root.trackerCount > 1 ? root.trackerCount : null
				delegate: SolarTrackerDailyHistory {
					uidPrefix: overallDailyHistoryDelegate.uidPrefix + "/Pv/" + model.index
				}
			}

			property bool _completed

			// uid is e.g. com.victronenergy.root.tty0/History/Daily/<day>
			uidPrefix: root.bindPrefix + "/History/Daily/" + model.index

			onYieldKwhChanged: {
				if (_completed) {
					root.yieldUpdatedForDay(model.index, yieldKwh)
				}
			}

			Component.onCompleted: {
				_completed = true
				if (!isNaN(yieldKwh)) {
					root.yieldUpdatedForDay(model.index, yieldKwh)
				}
			}
		}
	}

	readonly property VeQuickItem _veHistoryCount: VeQuickItem {
		uid: root.bindPrefix + "/History/Overall/DaysAvailable"
		onValueChanged: {
			if (value !== undefined) {
				_historyObjects.model = value
			}
		}
	}

}
