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
			createCharger({
				position: i % 2 === 0 ? VenusOS.PvInverter_Position_ACInput : VenusOS.PvInverter_Position_ACOutput
			})
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

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000

				onTriggered: {
					const zeroPower = Math.random() < 0.2
					const phase1Power = zeroPower ? 0 : Math.random() * 50
					const phase2Power = zeroPower ? 0 : Math.random() * 50
					const phase3Power = zeroPower ? 0 : Math.random() * 50
					phases.get(0)._power.setValue(phase1Power)
					phases.get(1)._power.setValue(phase2Power)
					phases.get(2)._power.setValue(phase3Power)

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

				// Set default values
				_maxCurrent.setValue(30)
				_customName.setValue("EV Charger " + deviceInstance)
				_productId.setValue(0xC025)
				_status.setValue(Math.floor(Math.random() * VenusOS.Evcs_Status_Charged))
				_mode.setValue(Math.floor(Math.random() * VenusOS.Evcs_Mode_Auto))
				_chargingTime.setValue(100000)
				_position.setValue(1)

				Global.mockDataSimulator.setMockValue(serviceUid + "/StartStop", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/AutoStart", 1)
				Global.mockDataSimulator.setMockValue(serviceUid + "/EnableDisplay", 1)

				// Device info
				Global.mockDataSimulator.setMockValue(serviceUid + "/Mgmt/Connection", serviceUid)
				Global.mockDataSimulator.setMockValue(serviceUid + "/Connected", 1)

				// Immediately queue an update so that the Brief/Overview pages update sooner for
				// UI testing.
				Qt.callLater(Global.evChargers._doUpdateTotals)
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
