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
			name: "GPS, no motordrives",
			gps: {},
		},
		{
			name: "GPS, single-drive",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
			],
		},
		{
			name: "GPS, single-drive, shore power connected",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
			],
			shorePowerConnected: true
		},
		{
			name: "GPS, single-drive, time to go, range, consumption",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
			],
			timeToGo: 123456,
			range: 58,
			consumptionWhkm: 150,
			consumptionAhkm: 3,
		},
		{
			name: "GPS, single-drive, time to go, regeneration",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: -1000 },
			],
			timeToGo: 123456
		},
		{
			name: "GPS, dual-drive",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
				{ productName: "Motor drive B", power: 1000 },
			],
		},
		{
			name: "GPS, dual-drive, time to go, range, consumption",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
				{ productName: "Motor drive B", power: 1000 },
			],
			timeToGo: 123456,
			range: 58,
			consumptionWhkm: 150,
			consumptionAhkm: 3,
		},
		{
			name: "GPS, dual-drive, time to go, regeneration",
			gps: {},
			motorDrives: [
				{ productName: "Motor drive A", power: -1000 },
				{ productName: "Motor drive B", power: -1000 },
			],
			timeToGo: 123456
		},
		{
			name: "No GPS, single-drive",
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
			],
		},
		{
			name: "No GPS, single-drive, regeneration",
			motorDrives: [
				{ productName: "Motor drive A", power: -1000 },
			],
		},
		{
			name: "No GPS, dual-drive",
			motorDrives: [
				{ productName: "Motor drive A", power: 1000 },
				{ productName: "Motor drive B", power: 1000 },
			],
		},
		{
			name: "No GPS, no motordrives"
		},
		{
			name: "No GPS, no motordrives, shore power connected",
			shorePowerConnected: true
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
		MockManager.setValue(Global.system.serviceUid + "/GpsSpeed", undefined)
		while (motorDriveServices.count > 0) {
			MockManager.removeValue(motorDriveServices.uidAt(motorDriveServices.count - 1))
			MockManager.setValue(Global.system.serviceUid + "/MotorDrive/0/DeviceInstance", undefined)
			MockManager.setValue(Global.system.serviceUid + "/MotorDrive/1/DeviceInstance", undefined)
		}

		// Ensure max values are present
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max", 3000)
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gps/SpeedUnit", "kt")
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Speed/Max", 6)
		MockManager.setValue(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/Power/Max", 11000)

		// Add new services if needed
		let deviceInstance
		let serviceUid
		if (config.gps) {
			deviceInstance = mockDeviceCount++
			serviceUid = "mock/com.victronenergy.gps.mock_%1".arg(deviceInstance)
			MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
			MockManager.setValue(serviceUid + "/ProductName", "GPS %1".arg(deviceInstance))
			MockManager.setValue(Global.system.serviceUid + "/GpsSpeed", Math.random() * MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/Speed/Max"))
		}
		if (config.motorDrives) {
			for (let i = 0; i < config.motorDrives.length; ++i) {
				deviceInstance = mockDeviceCount++
				serviceUid = "mock/com.victronenergy.motordrive.mock_%1".arg(deviceInstance)
				MockManager.setValue(serviceUid + "/DeviceInstance", deviceInstance)
				MockManager.setValue(serviceUid + "/ProductName", config.motorDrives[i].productName ?? "Motor drive %1".arg(deviceInstance))
				MockManager.setValue(serviceUid + "/Motor/Direction", Math.floor(Math.random() * 3))
				MockManager.setValue(serviceUid + "/Motor/RPM", Math.random() * MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/RPM/Max"))
				MockManager.setValue(serviceUid + "/Motor/Temperature", Math.random() * 100)
				MockManager.setValue(serviceUid + "/Coolant/Temperature", Math.random() * 100)
				MockManager.setValue(serviceUid + "/Controller/Temperature", Math.random() * 100)

				const power = config.motorDrives[i].power ?? Math.random() * MockManager.value(Global.systemSettings.serviceUid + "/Settings/Gui/Gauges/MotorDrive/Power/Max")
				const voltage = 50 + (Math.random() * 10)
				MockManager.setValue(serviceUid + "/Dc/0/Power", power)
				MockManager.setValue(serviceUid + "/Dc/0/Current", power / voltage)
				MockManager.setValue(serviceUid + "/Dc/0/Voltage", voltage)
				MockManager.setValue(serviceUid + "/Dc/0/Temperature", Math.random() * 100)

				MockManager.setValue(Global.system.serviceUid + "/MotorDrive/%1/DeviceInstance".arg(i), deviceInstance)
			}
		}
		if (config.shorePowerConnected) {
			MockManager.setValue(Global.system.serviceUid + "/Ac/In/1/Source", VenusOS.AcInputs_InputSource_Shore)
			MockManager.setValue(Global.system.serviceUid + "/Ac/ActiveIn/Source", VenusOS.AcInputs_InputSource_Shore)
			MockManager.setValue(MockManager.value(Global.system.serviceUid + "/Ac/In/1/ServiceName") + "/Ac/NumberOfPhases", 1)
		} else {
			MockManager.setValue(Global.system.serviceUid + "/Ac/In/1/Source", VenusOS.AcInputs_InputSource_Grid)
			MockManager.setValue(Global.system.serviceUid + "/Ac/ActiveIn/Source", VenusOS.AcInputs_InputSource_Grid)
			MockManager.setValue(MockManager.value(Global.system.serviceUid + "/Ac/In/1/ServiceName") + "/Ac/NumberOfPhases", 3)
		}
		MockManager.setValue(Global.system.serviceUid + "/Dc/Battery/TimeToGo", config.timeToGo ?? undefined)
		MockManager.setValue(Global.system.serviceUid + "/MotorDrive/Range", config.range ?? undefined)
		MockManager.setValue(Global.system.serviceUid + "/MotorDrive/ConsumptionWhkm", config.consumptionWhkm ?? undefined)
		MockManager.setValue(Global.system.serviceUid + "/MotorDrive/ConsumptionAhkm", config.consumptionAhkm ?? undefined)

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
