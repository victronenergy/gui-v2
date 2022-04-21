/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	function addInput(inputType, phaseCount) {
		let input = inputComponent.createObject(root, { "source": inputType, "phaseCount": phaseCount || 1 })
		model.append({ input: input })
	}

	function populate() {
		// Add a random set of AC inputs.
		model.clear()
		let types = [
				Enums.AcInputs_InputType_Grid,
				Enums.AcInputs_InputType_Generator,
				Enums.AcInputs_InputType_Shore,
			]
		// Have 2 inputs at most, to leave some space for DC inputs in overview page
		const modelCount = Math.floor(Math.random() * 2) + 1
		for (let i = 0; i < modelCount; ++i) {
			const index = Math.floor(Math.random() * types.length)
			addInput(types[index])
			types.splice(index, 1)
		}
	}

	Component {
		id: inputComponent

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
				running: true
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				onTriggered: input.connected = !input.connected
			}

			property Timer _dummyValues: Timer {
				running: true
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
		}
	}
}
