/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property SolarDeviceModel devices: SolarDeviceModel { }

	readonly property ServiceDeviceModel pvInverterDevices: ServiceDeviceModel {
		serviceTypes: ["pvinverter"]
		modelId: "pvinverter"
		deviceDelegate: PvInverter {
			id: pvInverter
			serviceUid: model.uid
			onValidChanged: {
				if (valid) {
					root.pvInverterDevices.addDevice(pvInverter)
				} else {
					root.pvInverterDevices.removeDevice(pvInverter.serviceUid)
				}
			}
		}
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
