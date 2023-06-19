/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Device {
	id: solarCharger

	property int state: _state.value === undefined ? -1 : _state.value
	readonly property ListModel trackers: ListModel {}

	property real voltage: NaN
	readonly property real current: isNaN(voltage) || isNaN(power) ? NaN : (!voltage || !power ? 0 : power / voltage)
	readonly property real power: _totalPower.value === undefined ? NaN : _totalPower.value

	readonly property real batteryVoltage: _batteryVoltage.value == undefined ? NaN : _batteryVoltage.value
	readonly property real batteryCurrent: _batteryCurrent.value == undefined ? NaN : _batteryCurrent.value
	readonly property real batteryTemperature: _batteryTemperature.value == undefined ? NaN : _batteryTemperature.value

	readonly property bool relayValid: _relay.value !== undefined
	readonly property bool relayOn: _relay.value === 1

	// This is the overall error history.
	// For the per-day error history, use dailyHistory(day).errorModel
	property SolarHistoryErrorModel errorModel: SolarHistoryErrorModel {
		uidPrefix: solarCharger.serviceUid + "/History/Overall"
	}

	signal yieldUpdatedForDay(day: int, yieldKwh: real)

	function dailyHistory(day, trackerIndex) {
		return _historyObjects.dailyHistory(day, trackerIndex)
	}

	//--- internal members below ---

	readonly property VeQuickItem _state: VeQuickItem {
		uid: solarCharger.serviceUid + "/State"
	}

	readonly property VeQuickItem _totalPower: VeQuickItem {
		uid: solarCharger.serviceUid + "/Yield/Power"
	}

	readonly property VeQuickItem _batteryVoltage: VeQuickItem {
		uid: solarCharger.serviceUid + "/Dc/0/Voltage"
	}

	readonly property VeQuickItem _batteryCurrent: VeQuickItem {
		uid: solarCharger.serviceUid + "/Dc/0/Current"
	}

	readonly property VeQuickItem _batteryTemperature: VeQuickItem {
		uid: solarCharger.serviceUid + "/Dc/0/Temperature"
	}

	readonly property VeQuickItem _relay: VeQuickItem {
		uid: solarCharger.serviceUid + "/Relay/0/State"
	}

	// --- history ---

	readonly property Instantiator _historyObjects: Instantiator {
		function dailyHistory(day, trackerIndex) {
			let overallDailyHistory = objectAt(day)
			if (trackerIndex === undefined
					|| trackerIndex < 0
					|| _trackerObjects.count <= 1) {    // When only 1 tracker, use the overall history instead
				return overallDailyHistory
			}
			return overallDailyHistory.trackerHistoryObjects.objectAt(trackerIndex)
		}

		model: undefined    // ensure delegates are not created before history model is set

		// The overall history for this day, for this charger (i.e. data includes all trackers).
		delegate: SolarDailyHistory {
			id: overallDailyHistoryDelegate

			// If there is more than one tracker, find the daily histories for each tracker, under
			// com.victronenergy.solarcharger.tty0/History/Daily/<day>/Pv/<pv-index>/Yield
			readonly property Instantiator trackerHistoryObjects: Instantiator {
				model: _trackerObjects.count > 1 ? _trackerObjects.count : null
				delegate: SolarDailyHistory {
					uidPrefix: overallDailyHistoryDelegate.uidPrefix + "/Pv/" + model.index
				}
			}

			property bool _completed

			// uid is e.g. com.victronenergy.solarcharger.tty0/History/Daily/<day>
			uidPrefix: solarCharger.serviceUid + "/History/Daily/" + model.index

			onYieldKwhChanged: {
				if (_completed) {
					solarCharger.yieldUpdatedForDay(model.index, yieldKwh)
				}
			}

			Component.onCompleted: {
				_completed = true
				if (!isNaN(yieldKwh)) {
					solarCharger.yieldUpdatedForDay(model.index, yieldKwh)
				}
			}
		}
	}

	readonly property VeQuickItem _veHistoryCount: VeQuickItem {
		uid: solarCharger.serviceUid + "/History/Overall/DaysAvailable"
		onValueChanged: {
			if (value !== undefined) {
				_historyObjects.model = value
			}
		}
	}

	//--- Solar trackers ---

	readonly property VeQuickItem _trackerCount: VeQuickItem {
		uid: solarCharger.serviceUid + "/NrOfTrackers"
	}

	readonly property Instantiator _trackerObjects: Instantiator {
		function _updateTotalVoltage() {
			let totalVoltage = NaN
			for (let i = 0; i < count; ++i) {
				const obj = objectAt(i)
				if (obj && !isNaN(obj.voltage)) {
					if (isNaN(totalVoltage)) {
						totalVoltage = 0
					}
					totalVoltage += obj.voltage
				}
			}
			solarCharger.voltage = totalVoltage
		}

		model: _trackerCount.value || 0
		delegate: Device {
			id: tracker

			readonly property int modelIndex: model.index
			readonly property real current: isNaN(voltage) || isNaN(power) ? NaN : (!voltage || !power ? 0 : power / voltage)
			readonly property real power: _trackerObjects.count <= 1 ? solarCharger.power : _power.value || 0
			readonly property real voltage: _voltage.value || 0

			readonly property VeQuickItem _voltage: VeQuickItem {
				uid: _trackerObjects.count <= 1
					 ? solarCharger.serviceUid + "/Pv/V"
					 : solarCharger.serviceUid + "/Pv/" + model.index + "/V"
				onValueChanged: {
					if (_completed) {
						_trackerObjects._updateTotalVoltage()
					}
				}
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: _trackerObjects.count === 1
					 ? ""   // only 1 tracker, use solarCharger.power instead (i.e. same as /Yield/Power)
					 : solarCharger.serviceUid + "/Pv/" + model.index + "/P"
			}

			property bool _completed

			serviceUid: solarCharger.serviceUid + "/Devices/" + (model.index)

			Component.onCompleted: _completed = true
		}

		onObjectAdded: function(index, object) {
			let insertionIndex = solarCharger.trackers.count
			for (let i = 0; i < solarCharger.trackers.count; ++i) {
				const sortIndex = solarCharger.trackers.get(i).solarTracker.modelIndex
				if (index < sortIndex) {
					insertionIndex = i
					break
				}
			}
			solarCharger.trackers.insert(insertionIndex, {"solarTracker": object})
		}

		onObjectRemoved: function(index, object) {
			for (let i = 0; i < solarCharger.trackers.count; ++i) {
				if (solarCharger.trackers.get(i).solarTracker.serviceUid === object.serviceUid) {
					solarCharger.trackers.remove(i)
					break
				}
			}
		}
	}

	property bool _valid: deviceInstance.value !== undefined
	on_ValidChanged: {
		if (_valid) {
			Global.solarChargers.addCharger(solarCharger)
		} else {
			Global.solarChargers.removeCharger(solarCharger)
		}
	}
}
