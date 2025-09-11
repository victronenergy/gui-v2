/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// solarcharger devices are always included in the model.
	// For multi and inverter devices, only include them if /NrOfTrackers > 0.
	readonly property FilteredDeviceModel devices: FilteredDeviceModel {
		serviceTypes: ["solarcharger", "multi", "inverter"]
		childFilterIds: { "multi": ["NrOfTrackers"], "inverter": ["NrOfTrackers"] }
		childFilterFunction: (device, childItems) => {
			return childItems["NrOfTrackers"]?.value > 0
		}
	}

	readonly property FilteredDeviceModel pvInverterDevices: FilteredDeviceModel {
		serviceTypes: "pvinverter"
	}

	readonly property int inputCount: devices.count + pvInverterDevices.count

	Component.onCompleted: Global.solarInputs = root
}
