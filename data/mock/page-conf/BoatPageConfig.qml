/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount

	readonly property var configs: [
		{
			name: "Motordrive, gps, km/h",
			gps: { speedUnit: "km/h"},
			motorDrive: {}
		},
		{
			name: "Motordrive, gps, m/s",
			gps: { speedUnit: "m/s"},
			motorDrive: {}
		},
		{
			name: "Motordrive, gps, kt",
			gps: { speedUnit: "kt"},
			motorDrive: {}
		},
		{
			name: "Motordrive, gps, mph",
			gps: { speedUnit: "mph"},
			motorDrive: {}
		},
		{
			name: "Motordrive, no gps",
			motorDrive: {}
		},
		{
			name: "No motordrive, gps",
			gps: { speedUnit: "kt"},
		},
		{
			name: "No motordrive, no gps"
		},
	]

	function configCount() {
		return configs.length
	}

	function loadConfig(configIndex) {
		const config = configs[configIndex]
		if (!config) return

		// Remove gps and motordrive services
		while (gpsServices.count > 0) {
			MockManager.removeValue(gpsServices.uidAt(gpsServices.count - 1))
		}
		while (motorDriveServices.count > 0) {
			MockManager.removeValue(motorDriveServices.uidAt(motorDriveServices.count - 1))
		}

		// Add new services if needed
		let deviceInstance
		let serviceUid
		if (config.gps) {
			deviceInstance = mockDeviceCount++
			serviceUid = "mock/com.victronenergy.gps.mock_%1".arg(deviceInstance)
			MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
			MockManager.setValue(serviceUid + "/ProductName", "GPS %1".arg(deviceInstance))
			MockManager.setValue(serviceUid + "/Speed", 100)
			MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit", config.gps.speedUnit)
		}
		if (config.motorDrive) {
			deviceInstance = mockDeviceCount++
			serviceUid = "mock/com.victronenergy.motordrive.mock_%1".arg(deviceInstance)
			MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
			MockManager.setValue(serviceUid + "/ProductName", "Motor drive %1".arg(deviceInstance))
			MockManager.setValue(serviceUid + "/Motor/Direction", Math.floor(Math.random() * 3))
			MockManager.setValue(serviceUid + "/Motor/RPM", Math.random() * MockManager.value(Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max"))
			MockManager.setValue(serviceUid + "/Motor/Temperature", Math.random() * 100)
			MockManager.setValue(serviceUid + "/Coolant/Temperature", Math.random() * 100)
			MockManager.setValue(serviceUid + "/Controller/Temperature", Math.random() * 100)
			const current = 50 + (Math.random() * 10)
			const voltage = 50 + (Math.random() * 10)
			MockManager.setValue(serviceUid + "/Dc/0/Power", current * voltage)
			MockManager.setValue(serviceUid + "/Dc/0/Current", current)
			MockManager.setValue(serviceUid + "/Dc/0/Voltage", voltage)
			MockManager.setValue(serviceUid + "/Dc/0/Temperature", Math.random() * 100)
		}

		return config.name
	}

	objectName: "BoatPageConfig"

	FilteredServiceModel {
		id: gpsServices
		serviceTypes: ["gps"]
	}

	FilteredServiceModel {
		id: motorDriveServices
		serviceTypes: ["motordrive"]
	}
}
