/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		// Add a random set of AC inputs.
		let types = [
				VenusOS.AcInputs_InputType_Grid,
				VenusOS.AcInputs_InputType_Generator,
				VenusOS.AcInputs_InputType_Shore,
			]
		// Have 2 inputs at most, to leave some space for DC inputs in overview page
		const modelCount = Math.floor(Math.random() * 2) + 1
		for (let i = 0; i < modelCount; ++i) {
			const index = Math.floor(Math.random() * types.length)
			const input = inputComponent.createObject(root, { "source": types[index] })
			_createdObjects.push(input)
			Global.acInputs.addInput(input)
			types.splice(index, 1)
		}
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetAcInputsRequested(config) {
			Global.acInputs.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.types.length; ++i) {
					const input = inputComponent.createObject(root, {
						source: config.types[i],
						phaseCount: config.phaseCount || 1
					})
					_createdObjects.push(input)
					Global.acInputs.addInput(input)
				}
			}
		}
	}

	property Component inputComponent: Component {
		QtObject {
			id: input

			property string serviceType
			property string serviceName
			property int source
			property bool connected
			property int productId: -1

			property real frequency
			property real current
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

			property Timer _dummyConnected: Timer {
				running: Global.demoManager.timersActive
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				triggeredOnStart: true
				onTriggered: {
					// Only 1 AC input is connected at a time. Randomly select a different input
					// as the connected one.
					for (let i = 0; i < Global.acInputs.model.count; ++i) {
						const currInput = Global.acInputs.model.get(i).input
						if (currInput === input) {
							currInput.connected = true
						} else {
							input.connected = false
						}
					}
				}
			}

			property Timer _dummyValues: Timer {
				running: Global.demoManager.timersActive
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
