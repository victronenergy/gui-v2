/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		// Add a random set of DC inputs.
		let types = [
				VenusOS.DcInputs_InputType_Alternator,
				VenusOS.DcInputs_InputType_DcGenerator,
				VenusOS.DcInputs_InputType_Wind,
			]
		// Have 2 inputs at most, to leave some space for AC inputs in overview page
		const modelCount = Math.floor(Math.random() * 2) + 1
		for (let i = 0; i < modelCount; ++i) {
			const index = Math.floor(Math.random() * types.length)
			const input = inputComponent.createObject(root, { "source": types[index] })
			_createdObjects.push(input)
			Global.dcInputs.addInput(input)
			types.splice(index, 1)
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetDcInputsRequested(config) {
			Global.dcInputs.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.types.length; ++i) {
					const input = inputComponent.createObject(root, { source: config.types[i] })
					_createdObjects.push(input)
					Global.dcInputs.addInput(input)
				}
			}
		}
	}

	property Component inputComponent: Component {
		MockDevice {
			id: input

			property int source

			property real voltage
			property real current
			property real power: (isNaN(voltage) || isNaN(current) || voltage === 0) ? NaN : voltage * current
			property real temperature_celsius

			property Timer _dummyValues: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				triggeredOnStart: true

				onTriggered: {
					let properties = ["voltage", "current", "temperature_celsius"]
					for (let propIndex = 0; propIndex < properties.length; ++propIndex) {
						let propTotal = 0
						const propName = properties[propIndex]
						let value = 0
						if (propName === "voltage") {
							value = 20 + Math.random() * 10
						} else if (propName === "current") {
							value = 1 + Math.random()
						} else if (propName === "temperature_celsius") {
							value = 50 + Math.random() * 50
						} else {
							console.warn("Unhandled property", propName)
						}

						input[propName] = value
					}
					Global.dcInputs.updateTotals()
				}
			}

			serviceUid: "com.victronenergy.dcsource.ttyUSB" + deviceInstance
			name: "DCInput" + deviceInstance
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
