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

	readonly property real power: _totalPower.isValid ? _totalPower.value : NaN
	readonly property alias history: _history

	// For solarcharger services, assume trackerCount=1 if /NrOfTrackers is not set.
	readonly property int trackerCount: _nrOfTrackers.isValid ? _nrOfTrackers.value : (_isSolarCharger ? 1 : 0)

	// This is the overall error history.
	// For the per-day error history, use dailyHistory(day).errorModel
	readonly property alias errorModel: _history.errorModel

	readonly property bool _isSolarCharger: BackendConnection.serviceTypeFromUid(serviceUid) === "solarcharger"

	signal yieldUpdatedForDay(day: int, yieldKwh: real)

	function dailyHistory(day) {
		return _history.dailyHistory(day)
	}

	function dailyTrackerHistory(day, trackerIndex) {
		return _history.dailyTrackerHistory(day, trackerIndex)
	}

	//--- internal members below ---

	readonly property VeQuickItem _totalPower: VeQuickItem {
		uid: root.serviceUid + "/Yield/Power"
	}

	readonly property VeQuickItem _nrOfTrackers: VeQuickItem {
		uid: root.serviceUid + "/NrOfTrackers"
	}

	//--- history ---

	readonly property SolarHistory _history: SolarHistory {
		id: _history
		bindPrefix: root.serviceUid
		deviceName: root.name
		trackerCount: root.trackerCount
	}
}
