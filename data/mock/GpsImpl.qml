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
		gpsComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.gps.ttyUSB0" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component gpsComponent: Component {
		Device {
			property int gear: VenusOS.MotorDriveGear_Forward
			property Timer t: Timer {
				interval: 1000
				running: Global.mockDataSimulator.timersActive
				repeat: true
				onTriggered: {
					Global.mockDataSimulator.setMockValue(serviceUid + "/Speed", Math.floor(Math.random() * 30))
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("GPS %1".arg(deviceInstance))
				_speedUnits.setValue("km/h")
			}
		}
	}

	property VeQuickItem _speedUnits : VeQuickItem {
		uid: Global.systemSettings.serviceUid  + "/Settings/Gps/SpeedUnit"
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetGpsRequested(config) {
			if (config) {
				setMockGpsValue(".tty2/ProductName", config.productName)
				setMockGpsValue(".tty2/DeviceInstance", config.deviceInstance)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
