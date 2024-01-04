/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	function populate() {
		// Add a random set of DC inputs.
		// Have 2 inputs at most, to leave some space for AC inputs in overview page
		const serviceTypes = ["alternator", "fuelcell", "dcsource"]
		const modelCount = Math.floor(Math.random() * 2) + 1
		for (let i = 0; i < modelCount; ++i) {
			const type = Math.floor(Math.random() * serviceTypes.length)
			const input = inputComponent.createObject(root, { "serviceType": serviceTypes[i] })
			_createdObjects.push(input)
			Global.dcInputs.addInput(input)
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
					const inputConfig = config.types[i]
					const input = inputComponent.createObject(root, {
						serviceType: inputConfig.serviceType,
						monitorMode: inputConfig.monitorMode
					})
					_createdObjects.push(input)
					Global.dcInputs.addInput(input)
				}
			}
		}
	}

	property Component inputComponent: Component {
		MockDevice {
			id: input

			readonly property int inputType: Global.dcInputs.inputType(serviceUid, monitorMode)
			property string serviceType
			property int monitorMode: -1    // generic DC source

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

			serviceUid: "mock/com.victronenergy." + serviceType + ".ttyUSB" + deviceInstance
			name: "DCInput" + deviceInstance
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
