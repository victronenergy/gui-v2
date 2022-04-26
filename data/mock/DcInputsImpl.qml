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
			Global.dcInputs.addInput(input)
			types.splice(index, 1)
		}
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetDcInputsRequested(config) {
			Global.dcInputs.model.clear()

			if (config) {
				for (let i = 0; i < config.types.length; ++i) {
					const input = inputComponent.createObject(root, { source: config.types[i] })
					Global.dcInputs.addInput(input)
				}
			}
		}
	}

	property Component inputComponent: Component {
		QtObject {
			id: input

			property int source

			property real voltage
			property real current
			property real temperature

			property Timer _dummyValues: Timer {
				running: Global.demoManager.timersActive
				repeat: true
				interval: 10000 + (Math.random() * 10000)
				triggeredOnStart: true

				onTriggered: {
					let properties = ["voltage", "current", "temperature"]
					for (let propIndex = 0; propIndex < properties.length; ++propIndex) {
						let propTotal = 0
						const propName = properties[propIndex]
						const value = Math.random() * 300
						input[propName] = value
					}
				}
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
