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

	function formatTrackerName(trackerName, trackerIndex, totalTrackerCount, deviceName, format) {
		if (format === VenusOS.TrackerName_WithDevicePrefix) {
			if (trackerName.length > 0) {
				return "%1-%2".arg(deviceName).arg(trackerName)
			} else if (totalTrackerCount > 1) {
				return "%1-#%2".arg(deviceName).arg(trackerIndex + 1)
			} else {
				return deviceName
			}
		} else {    // format === VenusOS.TrackerName_NoDevicePrefix
			if (trackerName.length > 0) {
				return trackerName
			} else {
				return "#%1".arg(trackerIndex + 1)
			}
		}
	}

	Component.onCompleted: Global.solarInputs = root
}
