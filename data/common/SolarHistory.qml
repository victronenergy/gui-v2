/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// The uid of the solarcharger/multi/inverter service
	required property string serviceUid

	readonly property int trackerCount: _nrOfTrackers.valid ? _nrOfTrackers.value
		// For solarcharger services, assume trackerCount=1 if /NrOfTrackers is not set.
		: (BackendConnection.serviceTypeFromUid(serviceUid) === "solarcharger" ? 1 : 0)
	readonly property int daysAvailable: _veHistoryCount.valid ? _veHistoryCount.value : 0
	readonly property bool ready: daysAvailable === _historyObjects.count

	function dailyHistory(day) {
		return _historyObjects.dailyHistory(day)
	}

	function dailyTrackerHistory(day, trackerIndex) {
		return _historyObjects.dailyTrackerHistory(day, trackerIndex)
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
			// com.victronenergy.solarcharger.tty0/History/Daily/<day>/Pv/<pv-index>
			readonly property Instantiator trackerHistoryObjects: Instantiator {
				model: root.trackerCount > 1 ? root.trackerCount : null
				delegate: SolarTrackerDailyHistory {
					uidPrefix: overallDailyHistoryDelegate.uidPrefix + "/Pv/" + model.index
				}
			}

			// uid is e.g. com.victronenergy.root.tty0/History/Daily/<day>
			uidPrefix: root.serviceUid + "/History/Daily/" + model.index
		}
	}

	readonly property VeQuickItem _veHistoryCount: VeQuickItem {
		uid: root.serviceUid + "/History/Overall/DaysAvailable"
		onValueChanged: {
			if (value !== undefined) {
				_historyObjects.model = value
			}
		}
	}

	readonly property VeQuickItem _nrOfTrackers: VeQuickItem {
		uid: root.serviceUid + "/NrOfTrackers"
	}
}
