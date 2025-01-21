/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// SolarDevice is a base type for devices with PV trackers and history data.
// This includes the devices provided by solarcharger services, as well as multi and inverter
// services where /NrOfTrackers > 0.

Device {
	id: root

	readonly property ListModel trackers: ListModel {}
	readonly property real power: _totalPower.isValid ? _totalPower.value : NaN
	readonly property alias history: _history

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
		return Global.solarDevices.formatTrackerName(trackerName, trackerIndex, trackers.count, root.name, format)
	}

	//--- internal members below ---

	readonly property VeQuickItem _totalPower: VeQuickItem {
		uid: root.serviceUid + "/Yield/Power"
	}

	//--- history ---

	readonly property SolarHistory _history: SolarHistory {
		id: _history
		bindPrefix: root.serviceUid
		deviceName: root.name
		trackerCount: root.trackers.count
	}

	//--- Solar trackers ---

	readonly property VeQuickItem _trackerCount: VeQuickItem {
		uid: root.serviceUid + "/NrOfTrackers"
	}

	readonly property Instantiator _trackerObjects: Instantiator {
		model: _trackerCount.value || 1     // there is always at least one tracker, even if NrOfTrackers is not set
		delegate: QtObject {
			id: tracker

			readonly property int modelIndex: model.index
			readonly property real power: root.trackers.count <= 1 ? root.power : _power.value || 0
			readonly property real voltage: _voltage.value || 0
			readonly property real current: isNaN(power) || isNaN(voltage) || voltage === 0 ? NaN : power / voltage
			readonly property string name: _name.value || ""

			readonly property VeQuickItem _voltage: VeQuickItem {
				uid: root.trackers.count <= 1
					 ? root.serviceUid + "/Pv/V"
					 : root.serviceUid + "/Pv/" + model.index + "/V"
			}

			readonly property VeQuickItem _power: VeQuickItem {
				uid: root.trackers.count === 1
					 ? ""   // only 1 tracker, use root.power instead (i.e. same as /Yield/Power)
					 : root.serviceUid + "/Pv/" + model.index + "/P"
			}

			readonly property VeQuickItem _name: VeQuickItem {
				uid: root.serviceUid + "/Pv/" + model.index + "/Name"
			}
		}

		onObjectAdded: function(index, object) {
			let insertionIndex = root.trackers.count
			for (let i = 0; i < root.trackers.count; ++i) {
				const sortIndex = root.trackers.get(i).solarTracker.modelIndex
				if (index < sortIndex) {
					insertionIndex = i
					break
				}
			}
			root.trackers.insert(insertionIndex, {"solarTracker": object})
		}

		onObjectRemoved: function(index, object) {
			for (let i = 0; i < root.trackers.count; ++i) {
				if (root.trackers.get(i).solarTracker.serviceUid === object.serviceUid) {
					root.trackers.remove(i)
					break
				}
			}
		}
	}
}
