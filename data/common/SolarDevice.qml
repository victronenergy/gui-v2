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

	readonly property real power: _totalPower.valid ? _totalPower.value : NaN

	// For solarcharger services, assume trackerCount=1 if /NrOfTrackers is not set.
	readonly property int trackerCount: _nrOfTrackers.valid ? _nrOfTrackers.value
			: (BackendConnection.serviceTypeFromUid(serviceUid) === "solarcharger" ? 1 : 0)

	//--- internal members below ---

	readonly property VeQuickItem _totalPower: VeQuickItem {
		uid: root.serviceUid + "/Yield/Power"
	}

	readonly property VeQuickItem _nrOfTrackers: VeQuickItem {
		uid: root.serviceUid + "/NrOfTrackers"
	}
}
