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
		Global.pvInverters.reset()

		const inverterCount = 3
		for (let i = 0; i < inverterCount; ++i) {
			const inverterObj = inverterComponent.createObject(root, {
				name: "My PV inverter " + i,
				phaseCount: i + 1,
			})
			_createdObjects.push(inverterObj)
		}
	}

	property Component inverterComponent: Component {
		PvInverter {
			id: pvInverter

			property int phaseCount

			property Timer _updates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				triggeredOnStart: true
				onTriggered: {
					if (pvInverter.phaseCount === 0) {
						return
					}
					const phaseIndex = Math.floor(Math.random() * pvInverter.phaseCount)
					const delta = Math.random() > 0.5 ? 1 : -1 // power may fluctuate up or down
					const power = (300 + Math.random() * 100) * delta
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Power".arg(phaseIndex + 1), power)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Current".arg(phaseIndex + 1), power * 0.01)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Voltage".arg(phaseIndex + 1), Math.random() * 30)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Energy/Forward".arg(phaseIndex + 1), Math.random() * 10)
					Qt.callLater(_updateTotals)
				}

				function _updateTotals() {
					let totalPower = NaN
					let totalEnergy = NaN
					for (let i = 0; i < pvInverter.phases.count; ++i) {
						totalPower = Units.sumRealNumbers(totalPower, pvInverter.phases.get(i).power)
						totalEnergy = Units.sumRealNumbers(totalEnergy, pvInverter.phases.get(i).energy)
					}
					const firstPhase = pvInverter.phases.get(0)
					if (!firstPhase) {
						return
					}
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/Power", totalPower)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/Current", !!firstPhase ? firstPhase.current : NaN)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/Voltage", !!firstPhase ? firstPhase.voltage : NaN)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/Energy/Forward", totalEnergy)
				}
			}

			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.pvinverter.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_customName.setValue("My PV Inverter " + deviceInstanceNum)
				_statusCode.setValue(Math.random() * VenusOS.PvInverter_StatusCode_Error)

				for (let phaseIndex = 0; phaseIndex < 3; ++phaseIndex) {
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Power".arg(phaseIndex + 1), NaN)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Current".arg(phaseIndex + 1), NaN)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Voltage".arg(phaseIndex + 1), NaN)
					Global.mockDataSimulator.setMockValue(serviceUid + "/Ac/L%1/Energy/Forward".arg(phaseIndex + 1), NaN)
				}
			}
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSolarRequested(config) {
			Global.pvInverters.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config && config.inverters) {
				for (let i = 0; i < config.inverters.length; ++i) {
					const inverterObj = inverterComponent.createObject(root, {
						phaseCount: config.inverters[i].phaseCount || 1,
					})
					_createdObjects.push(inverterObj)
				}
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
