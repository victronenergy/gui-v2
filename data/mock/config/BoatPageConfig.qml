/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var emptyAcInput: ({
											 source: VenusOS.AcInputs_InputSource_NotAvailable,
											 serviceType: "",
											 serviceName: "",
											 connected: 0,
											 phaseCount: 0,
										 })

	readonly property var configs: [
		{
			name: "Motordrive, gps, km/h",
			gps: { productName: "GPS device 2", deviceInstance: 1, speedUnit: "km/h"},
			motorDrive: { serviceUid: "mock/com.victronenergy.motordrive.tty3" }
		},
		{
			name: "Motordrive, gps, m/s",
			gps: { productName: "GPS device 2", deviceInstance: 1, speedUnit: "m/s"},
			motorDrive: { serviceUid: "mock/com.victronenergy.motordrive.tty3" }
		},
		{
			name: "Motordrive, gps, kt",
			gps: { productName: "GPS device 2", deviceInstance: 1, speedUnit: "kt"},
			motorDrive: { serviceUid: "mock/com.victronenergy.motordrive.tty3" }
		},
		{
			name: "Motordrive, gps, mph",
			gps: { productName: "GPS device 2", deviceInstance: 1, speedUnit: "mph"},
			motorDrive: { serviceUid: "mock/com.victronenergy.motordrive.tty3" }
		},
		{
			name: "Motordrive, no gps",
			motorDrive: { serviceUid: "mock/com.victronenergy.motordrive.tty3" }
		},
		{
			name: "No motordrive, gps",
			gps: { productName: "GPS device 2", deviceInstance: 1, speedUnit: "kt"},
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

		const gps = config.gps
		const motorDrive = config.motorDrive

		Global.allDevicesModel.gpsDevices.clear()
		Global.allDevicesModel.motorDriveDevices.clear()

		if (gps) {
			gpsComponent.createObject(root, {
										  serviceUid: "mock/com.victronenergy.gps.tty2",
										  deviceInstance: gps.deviceInstance
									  })
			_speedUnit.setValue(gps.speedUnit)
		}

		if (motorDrive) {
			motorDriveComponent.createObject(root, {
												 serviceUid: motorDrive.serviceUid,
												 deviceInstance: 1
											 })
		}

		return config.name
	}

	property VeQuickItem _speedUnit : VeQuickItem {
		uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	property Component gpsComponent: Component {
		Device {
			id: gps

			Component.onCompleted: {
				Global.allDevicesModel.gpsDevices.addDevice(gps)
			}
		}
	}

	property Component motorDriveComponent: Component {
		Device {
			id: motorDrive

			serviceUid: "mock/com.victronenergy.motordrive.tty3"
			Component.onCompleted: {
				Global.allDevicesModel.motorDriveDevices.addDevice(motorDrive)
			}
		}
	}

	property Timer motorDriveTimer: Timer {
		property int gear: VenusOS.MotorDriveGear_Forward
		property var motorDrive: Global.allDevicesModel.motorDriveDevices.deviceAt(0)
		property var serviceUid: motorDrive ? motorDrive.serviceUid : ""

		interval: 1000
		running: Global.allDevicesModel.motorDriveDevices.count > 0
		repeat: true
		onTriggered: {
			var serviceUid = Global.allDevicesModel.motorDriveDevices.deviceAt(0).serviceUid
			if (++gear > VenusOS.MotorDriveGear_Forward) {
				gear = VenusOS.MotorDriveGear_Neutral
			}

			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/RPM", Math.floor(Math.random() * 4000))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Dc/0/Power", Math.floor(Math.random() * 12345))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Dc/0/Current", Math.floor(Math.random() * 234))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Direction", gear)
			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Temperature", Math.floor(Math.random() * 100))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Coolant/Temperature", Math.floor(Math.random() * 100))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Controller/Temperature", Math.floor(Math.random() * 100))
		}
	}

	property Timer gpsTimer: Timer {
		interval: 1000
		running: Global.allDevicesModel.gpsDevices.count > 0
		repeat: true
		onTriggered: {
			Global.mockDataSimulator.setMockValue(Global.allDevicesModel.gpsDevices.deviceAt(0).serviceUid + "/Speed", Math.floor(Math.random() * 30))
		}
	}
	objectName: "BoatPageConfig"
}
