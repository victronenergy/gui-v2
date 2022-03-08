/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data" as DBusData

Item {
	id: root

	property ListModel model: ListModel {}

	function addInput(inputType) {
		let input = inputComponent.createObject(root, { "source": inputType })
		model.append({ input: input })
	}

	function populate() {
		// Add a random set of DC inputs.
		model.clear()
		let types = [
				DBusData.DcInputs.InputType.Alternator,
				DBusData.DcInputs.InputType.DcGenerator,
				DBusData.DcInputs.InputType.Wind,
			]
		// Have 2 inputs at most, to leave some space for AC inputs in overview page
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

			property int source

			property real voltage
			property real current
			property real temperature

			property Timer _dummyValues: Timer {
				running: true
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
}
