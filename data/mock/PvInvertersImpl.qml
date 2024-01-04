/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		Global.pvInverters.reset()

		const inverterCount = 3
		for (let i = 0; i < inverterCount; ++i) {
			const inverterObj = inverterComponent.createObject(root, {
				name: "My PV inverter " + i,
				phaseCount: i + 1,
			})
			_createdObjects.push(inverterObj)

			Global.pvInverters.addInverter(inverterObj)
		}
	}

	property Component inverterComponent: Component {
		MockDevice {
			id: pvInverter

			property int statusCode: Math.random() * VenusOS.PvInverter_StatusCode_Error
			property int errorCode: -1
			property int phaseCount

			readonly property ListModel phases: ListModel {
				Component.onCompleted: {
					for (let i = 0; i < phaseCount; ++i) {
						let phaseData = { name: "L"+(i+1), energy: Math.random() * 1000, power: Math.random() * 100, voltage: 1 + (Math.random() * 5)}
						phaseData.current = phaseData.power / phaseData.voltage
						append(phaseData)
					}
				}
			}

			property real energy: Math.random() * 10
			readonly property real current: NaN // multi-phase systems don't have a total current
			property real power: Math.random() * 50
			property real voltage: Math.random() * 30

			property Timer _updates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000
				onTriggered: {
					if (phases.count === 0) {
						return
					}
					const phaseIndex = Math.floor(Math.random() * phases.count)
					const phase = phases.get(phaseIndex)
					const delta = Math.random() > 0.5 ? 1 : -1 // power may fluctuate up or down
					pvInverter.power -= phase.power
					phase.power = Math.max(0, phase.power + (1 + (Math.random() * 10)) * delta)
					pvInverter.power += phase.power
					pvInverter.energy = Math.random() * 10
					pvInverter.voltage = Math.random() * 30
				}
			}

			serviceUid: "mock/com.victronenergy.pvinverter.ttyUSB" + deviceInstance
			name: "PV Inverter " + deviceInstance
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
						statusCode: config.inverters[i].statusCode || VenusOS.PvInverter_StatusCode_Running,
						power: config.inverters[i].power,
					})
					_createdObjects.push(inverterObj)

					Global.pvInverters.addInverter(inverterObj)
				}
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
