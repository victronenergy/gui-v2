/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount

	function populate() {
		const deviceInstanceNum = mockDeviceCount++
		motorDriveComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.motordrive.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component motorDriveComponent: Component {
		Device {
			property int gear: VenusOS.MotorDriveGear_Forward
			property Timer t: Timer {
				interval: 1000
				running: Global.mockDataSimulator.timersActive
				repeat: true
				onTriggered: {
					if (++gear > VenusOS.MotorDriveGear_Forward) {
						gear = VenusOS.MotorDriveGear_Neutral
					}

					Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/RPM", Math.floor(Math.random() * 4000))

					power.setValue(Math.floor(Math.random() * 12345))
					Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Direction", gear)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Motor/Temperature", Math.floor(Math.random() * 100))
					Global.mockDataSimulator.setMockValue(serviceUid + "/Coolant/Temperature", Math.floor(Math.random() * 100))
					Global.mockDataSimulator.setMockValue(serviceUid + "/Controller/Temperature", Math.floor(Math.random() * 100))
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("Motor Drive %1".arg(deviceInstance))
			}
		}
	}

	readonly property VeQuickItem power: VeQuickItem {
		uid: BackendConnection.serviceUidForType("system") + "/MotorDrive/Power"
	}

	Component.onCompleted: {
		populate()
	}
}
