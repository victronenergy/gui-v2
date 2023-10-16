/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		// Add all possible AC inputs (only one will be connected at any time)
		let types = [
				VenusOS.AcInputs_InputType_Grid,
				VenusOS.AcInputs_InputType_Generator,
				VenusOS.AcInputs_InputType_Shore,
			]
		for (let i = 0; i < types.length; ++i) {
			const input = inputComponent.createObject(root, { "source": types[i] })
			_createdObjects.push(input)
			Global.acInputs.addInput(input)
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetAcInputsRequested(config) {
			Global.acInputs.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			// disable connection changes temporarily so that the UI will show the
			// connected input as requested
			_disableAutoConnectedChanges.start()

			if (config) {
				const input = inputComponent.createObject(root, {
					source: config.type,
					phaseCount: config.phaseCount || 1
				})
				_createdObjects.push(input)
				Global.acInputs.addInput(input)

				for (let i = 0; i < Global.acInputs.model.count; ++i) {
					if (input.source === config.type && config.connected) {
						input.connected = true
					} else {
						input.connected = false
					}
				}
			}
		}
	}

	property Timer _disableAutoConnectedChanges: Timer {
		interval: 5000
	}

	property Timer _dummyConnected: Timer {
		running: Global.mockDataSimulator.timersActive && !_disableAutoConnectedChanges.running
		repeat: true
		interval: 10000 + (Math.random() * 10000)
		triggeredOnStart: true
		onTriggered: {
			// Only 1 AC input is connected at a time. Randomly select a different input
			// as the connected one.
			let randomIndex = Math.floor(Math.random() * Global.acInputs.model.count)
			if (Math.random() < 0.2) {
				randomIndex = -1    // sometimes, just disconnect all inputs
			}
			for (let i = 0; i < Global.acInputs.model.count; ++i) {
				const currInput = Global.acInputs.model.deviceAt(0)
				if (i === randomIndex) {
					currInput.connected = true
				} else {
					currInput.connected = false
				}
			}
		}
	}

	property Component inputComponent: Component {
		MockDevice {
			id: input

			property string serviceType
			property string serviceName
			property int source
			property bool connected
			property int productId: -1

			property real frequency
			property real current
			property real currentLimit: NaN
			property real power
			property real voltage
			property ListModel phases: ListModel {
				Component.onCompleted: {
					for (let i = 0; i < phaseCount; ++i) {
						append({ name: "L" + (i+1), frequency: NaN, current: NaN, power: NaN, voltage: NaN })
					}
				}
			}

			property int phaseCount: 1

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				triggeredOnStart: true

				onTriggered: {
					// Positive energy value = imported energy, flowing towards inverter/charger.
					// Negative energy value = exported energy, flowing towards grid.
					const negativeEnergyFlow = Math.random() > 0.5
					const zeroEnergyFlow = Math.random() > 0.8
					let properties = ["frequency", "current", "power", "voltage"]
					for (let propIndex = 0; propIndex < properties.length; ++propIndex) {
						let propTotal = 0
						const propName = properties[propIndex]
						for (let i = 0; i < input.phaseCount; ++i) {
							if (zeroEnergyFlow) {
								input.phases.setProperty(i, propName, NaN)
							} else {
								const value = negativeEnergyFlow && (propName === "power" || propName === "current")
											? (Math.random() * 300) * -1
											: Math.random() * 300
								input.phases.setProperty(i, propName, value)
								propTotal += value
							}
						}
						input[propName] = propTotal
					}
				}
			}

			serviceUid: "com.victronenergy.system/Ac/In" + deviceInstance
			name: "ACInput" + deviceInstance

			onConnectedChanged: {
				if (connected) {
					Global.acInputs.connectedInput = input
				} else if (!connected && Global.acInputs.connectedInput === input) {
					Global.acInputs.connectedInput = null
				}
			}

			Component.onCompleted: {
				if (source === VenusOS.AcInputs_InputType_Generator) {
					Global.acInputs.generatorInput = input
				}
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
