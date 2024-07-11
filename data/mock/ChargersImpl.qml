/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property int mockDeviceCount

	function populate() {
		const deviceInstanceNum = mockDeviceCount++
		chargerComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.charger.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
	}

	property Component chargerComponent: Component {
		Charger {
			id: charger

			property int inputCount: 1 + Math.floor(Math.random() * 2)

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			property Timer _measurementUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					for (let i = 0; i < charger.inputCount; ++i) {
						charger.setMockValue("/Dc/%1/Voltage".arg(i+1), Math.random() * 50)
						charger.setMockValue("/Dc/%1/Current".arg(i+1), Math.random() * 10)
					}
					charger.setMockValue("/Ac/In/L1/I", Math.random() * 10)
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_customName.setValue("AC Charger " + deviceInstance)
				_productName.setValue("Skylla-i")
				charger.setMockValue("/Mode", 1)
				charger.setMockValue("/State", Math.floor(Math.random() * VenusOS.System_State_FaultCondition))
				charger.setMockValue("/Ac/In/CurrentLimit", Math.random() * 30)
				charger.setMockValue("/NrOfOutputs", inputCount)
				charger.setMockValue("/Alarms/LowVoltage", Math.floor(Math.random() * VenusOS.Alarm_Level_Alarm))
				charger.setMockValue("/Alarms/HighVoltage", Math.floor(Math.random() * VenusOS.Alarm_Level_Alarm))
				charger.setMockValue("/ErrorCode", Math.floor(Math.random() * 5))
				charger.setMockValue("/Relay/0/State", 1)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
