/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Device {
	id: solarCharger

	readonly property int state: _state.value === undefined ? -1 : _state.value
	readonly property int errorCode: _errorCode.value === undefined ? -1 : _errorCode.value
	readonly property ListModel trackers: ListModel {}
	readonly property real power: _totalPower.value === undefined ? NaN : _totalPower.value
	readonly property alias history: _history

	readonly property real batteryVoltage: _batteryVoltage.value == undefined ? NaN : _batteryVoltage.value
	readonly property real batteryCurrent: _batteryCurrent.value == undefined ? NaN : _batteryCurrent.value
	readonly property real batteryTemperature: _batteryTemperature.value == undefined ? NaN : _batteryTemperature.value

	readonly property bool relayValid: _relay.value !== undefined
	readonly property bool relayOn: _relay.value === 1

	// This is the overall error history.
	// For the per-day error history, use dailyHistory(day).errorModel
	readonly property alias errorModel: _history.errorModel

	signal yieldUpdatedForDay(day: int, yieldKwh: real)

	function dailyHistory(day) {
		return _history.dailyHistory(day)
	}

	function dailyTrackerHistory(day, trackerIndex) {
		return _history.dailyTrackerHistory(day, trackerIndex)
	}

	function trackerName(trackerIndex, format) {
		const tracker = _trackerObjects.objectAt(trackerIndex)
		const trackerName = tracker ? tracker.name || "" : ""
		return Global.solarChargers.formatTrackerName(trackerName, trackerIndex, trackers.count, solarCharger.name, format)
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

	readonly property VeQuickItem _errorCode: VeQuickItem {
		uid: solarCharger.serviceUid + "/ErrorCode"
	}

	//--- history ---

	readonly property SolarHistory _history: SolarHistory {
		id: _history
		bindPrefix: solarCharger.serviceUid
		deviceName: solarCharger.name
		trackerCount: solarCharger.trackers.count
	}

	//--- Solar trackers ---

	readonly property VeQuickItem _trackerCount: VeQuickItem {
		uid: solarCharger.serviceUid + "/NrOfTrackers"
	}

	readonly property Instantiator _trackerObjects: Instantiator {
		model: _trackerCount.value || 1     // there is always at least one tracker, even if NrOfTrackers is not set
		delegate: QtObject {
			id: tracker

			readonly property int modelIndex: model.index
			readonly property real power: solarCharger.trackers.count <= 1 ? solarCharger.power : _power.value || 0
			readonly property real voltage: _voltage.value || 0
			readonly property real current: isNaN(power) || isNaN(voltage) || voltage === 0 ? NaN : power / voltage
			readonly property string name: _name.value || ""

			readonly property VeQuickItem _voltage: VeQuickItem {
				uid: solarCharger.trackers.count <= 1
					 ? solarCharger.serviceUid + "/Pv/V"
					 : solarCharger.serviceUid + "/Pv/" + model.index + "/V"
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: solarCharger.trackers.count === 1
					 ? ""   // only 1 tracker, use solarCharger.power instead (i.e. same as /Yield/Power)
					 : solarCharger.serviceUid + "/Pv/" + model.index + "/P"
			}

			readonly property VeQuickItem _name: VeQuickItem {
				uid: solarCharger.serviceUid + "/Pv/" + model.index + "/Name"
			}
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

	onValidChanged: {
		if (!!Global.solarChargers) {
			if (valid) {
				Global.solarChargers.addCharger(solarCharger)
			} else {
				Global.solarChargers.removeCharger(solarCharger)
			}
		}
	}
}
