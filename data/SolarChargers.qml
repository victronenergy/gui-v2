/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	// Model of all solar chargers
	property DeviceModel model: DeviceModel {
		modelId: "solarChargers"
	}

	function addCharger(charger) {
		model.addDevice(charger)
	}

	function removeCharger(charger) {
		model.removeDevice(charger.serviceUid)
	}

	function reset() {
		model.clear()
	}

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

	Component.onCompleted: Global.solarChargers = root
}
