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
		for (let i = 0; i < 3; ++i) {
			createCharger({ status: Math.random() * VenusOS.Evcs_Status_Charged, mode: VenusOS.Evcs_Mode_Auto })
		}
	}

	function createCharger(config) {
		const deviceInstanceNum = mockDeviceCount++
		const charger = chargerComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.evcharger.ttyUSB" + deviceInstanceNum,
			deviceInstance: deviceInstanceNum,
		})
		for (const configProperty in config) {
			const configValue = config[configProperty]
			charger["_" + configProperty].setValue(configValue)
		 }
		_createdObjects.push(charger)
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetEvChargersRequested(config) {
			Global.evChargers.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					createCharger(config.chargers[i])
				}
			}
		}
	}

	property Component chargerComponent: Component {
		EvCharger {
			id: evCharger

			readonly property ListModel phases: ListModel {
				ListElement { name: "L1"; power: 10 }
				ListElement { name: "L2"; power: 20 }
				ListElement { name: "L3"; power: 30 }
			}

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000

				onTriggered: {
					const phase1Power = Math.random() * 50
					const phase2Power = Math.random() * 50
					const phase3Power = Math.random() * 50
					_phase1Power.setValue(phase1Power)
					_phase2Power.setValue(phase2Power)
					_phase3Power.setValue(phase3Power)

					_energy.setValue(1 + Math.random() * 10)
					_current.setValue(1 + Math.random() * 20)
					_power.setValue(phase1Power + phase2Power + phase3Power)
					_chargingTime.setValue(chargingTime + 60)
				}
			}

			property Timer _statusChange: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 3000

				onTriggered: {
					evCharger._status.setValue(Math.random() * VenusOS.Evcs_Status_OverheatingDetected)
				}
			}

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_maxCurrent.setValue(30)
				_customName.setValue("EV Charger " + deviceInstance)
				_productId.setValue(0xC025)
				_chargingTime.setValue(100000)

				Global.mockDataSimulator.setMockValue(serviceUid + "/Position", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/StartStop", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/AutoStart", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/EnableDisplay", 1)

				// Device info
				Global.mockDataSimulator.setMockValue(serviceUid + "/Mgmt/Connection", serviceUid)
				Global.mockDataSimulator.setMockValue(serviceUid + "/Connected", 1)
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
