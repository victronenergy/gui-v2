/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../common"

QtObject {
	id: root

	function populate() {
		Global.pvInverters.reset()

		const inverterCount = 3
		for (let i = 0; i < inverterCount; ++i) {
			const inverterObj = inverterComponent.createObject(root, {
				name: "My PV inverter " + i
			})
			_createdObjects.push(inverterObj)

			Global.pvInverters.addInverter(inverterObj)
		}
	}

	property int _objectId
	property Component inverterComponent: Component {
		MockDevice {
			id: pvInverter

			readonly property string serviceUid: "com.victronenergy.pvinverter.ttyUSB" + deviceInstance.value
			property int statusCode: Math.random() * VenusOS.PvInverter_StatusCode_Error

			readonly property ListModel phases: ListModel {
				ListElement { name: "L1"; energy: 1.5; power: 20; current: 5; voltage: 10 }
				ListElement { name: "L2"; energy: 3; power: 30; current: 10; voltage: 15 }
				ListElement { name: "L3"; energy: 4.5; power: 40; current: 15; voltage: 20 }
			}

			property real energy: Math.random() * 10
			property real current: Math.random() * 20
			property real power: Math.random() * 50
			property real voltage: Math.random() * 30

			property Timer _updates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000
				onTriggered: {
					const phaseIndex = Math.floor(Math.random() * phases.count)
					const phase = phases.get(phaseIndex)
					const delta = Math.random() > 0.5 ? 1 : -1 // power may fluctuate up or down
					pvInverter.power -= phase.power
					phase.power = Math.max(0, phase.power + (1 + (Math.random() * 10)) * delta)
					pvInverter.power += phase.power
					pvInverter.energy = Math.random() * 10
					pvInverter.current = Math.random() * 20
					pvInverter.voltage = Math.random() * 30
				}
			}

			name: "PV Inverter " + deviceInstance.value
			Component.onCompleted: deviceInstance.value = root._objectId++
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
