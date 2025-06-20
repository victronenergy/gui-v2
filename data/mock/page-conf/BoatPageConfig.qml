/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

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
			motorDriveComponent.createObject(
						root, {
							serviceUid: motorDrive.serviceUid,
							deviceInstance: 1
						})
		}

		return config.name
	}

	readonly property VeQuickItem _speedUnit : VeQuickItem {
		uid: Global.systemSettings ? Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit" : ""
	}

	readonly property Component gpsComponent: Component {
		Device {
			id: gps

			Component.onCompleted: {
				Global.allDevicesModel.gpsDevices.addDevice(gps)
			}
		}
	}

	readonly property Component motorDriveComponent: Component {
		Device {
			id: motorDrive

			serviceUid: "mock/com.victronenergy.motordrive.tty3"
			Component.onCompleted: {
				Global.allDevicesModel.motorDriveDevices.addDevice(motorDrive)
			}
		}
	}

	readonly property Timer motorDriveTimer: Timer {
		property int gear: VenusOS.MotorDriveGear_Forward
		readonly property Device motorDrive: Global.allDevicesModel.motorDriveDevices.deviceAt(0)
		readonly property string serviceUid: motorDrive ? motorDrive.serviceUid : ""

		interval: 1000
		running: Global.mockDataSimulator.timersActive && Global.allDevicesModel.motorDriveDevices.count > 0
		repeat: true
		onTriggered: {
			const serviceUid = Global.allDevicesModel.motorDriveDevices.deviceAt(0).serviceUid
			if (++gear > VenusOS.MotorDriveGear_Forward) {
				gear = VenusOS.MotorDriveGear_Neutral
			}

			power.setValue(Math.floor(Math.random() * 12345))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/RPM", Math.floor(Math.random() * 4000))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Direction", gear)
			Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Temperature", Math.floor(Math.random() * 100))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Coolant/Temperature", Math.floor(Math.random() * 100))
			Global.mockDataSimulator.setMockValue(serviceUid + "/Controller/Temperature", Math.floor(Math.random() * 100))
		}
	}

	readonly property Timer gpsTimer: Timer {
		interval: 1000
		running: Global.mockDataSimulator.timersActive && Global.allDevicesModel.gpsDevices.count > 0
		repeat: true
		onTriggered: {
			Global.mockDataSimulator.setMockValue(Global.allDevicesModel.gpsDevices.deviceAt(0).serviceUid + "/Speed", Math.floor(Math.random() * 30))
		}
	}

	readonly property VeQuickItem power: VeQuickItem {
		uid: BackendConnection.serviceUidForType("system") + "/MotorDrive/Power"
	}

	objectName: "BoatPageConfig"
}
