/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount
	property Device gpsDevice
	property Device motorDriveDevice

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

		if (!gpsDevice) {
			gpsDevice = findGpsDevice()
		}
		if (!motorDriveDevice) {
			motorDriveDevice = findMotorDriveDevice()
		}

		Global.allDevicesModel.gpsDevices.clear()
		Global.allDevicesModel.motorDriveDevices.clear()

		if (config.gps) {
			Global.allDevicesModel.gpsDevices.addDevice(gpsDevice)
			MockManager.setValue(Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit", config.gps.speedUnit)
		}
		if (config.motorDrive) {
			Global.allDevicesModel.motorDriveDevices.addDevice(motorDriveDevice)
		}

		return config.name
	}

	function findGpsDevice() {
		if (Global.allDevicesModel.gpsDevices.count === 0) {
			const deviceInstance = mockDeviceCount++
			const serviceUid = "mock/com.victronenergy.gps.mock_%1".arg(deviceInstance)
			MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
			MockManager.setValue(serviceUid + "/ProductName", "GPS %1".arg(deviceInstance))
		}
		return Global.allDevicesModel.gpsDevices.firstObject
	}

	function findMotorDriveDevice() {
		if (Global.allDevicesModel.motorDriveDevices.count === 0) {
			const deviceInstance = mockDeviceCount++
			const serviceUid = "mock/com.victronenergy.motordrive.mock_%1".arg(deviceInstance)
			MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
			MockManager.setValue(serviceUid + "/ProductName", "Motor drive %1".arg(deviceInstance))
			MockManager.setValue(serviceUid + "/Motor/RPM", Math.random() * MockManager.value(Global.systemSettings.serviceUid  + "/Settings/Gui/Gauges/Speed/Max"))
		}
		return Global.allDevicesModel.motorDriveDevices.firstObject
	}

	objectName: "BoatPageConfig"
}
