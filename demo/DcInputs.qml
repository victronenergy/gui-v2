/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "../data" as DBusData

Item {
	id: root

	property ListModel model: ListModel {
		Component.onCompleted: _populateModel()
	}

	function _populateModel() {
		// Add a random set of DC inputs.
		model.clear()
		let types = [
				DBusData.DcInputs.InputType.Alternator,
				DBusData.DcInputs.InputType.DcGenerator,
				DBusData.DcInputs.InputType.Wind,
			]
		const modelCount = Math.floor(Math.random() * types.length) + 1  // from zero to all types
		for (let i = 0; i < modelCount; ++i) {
			const index = Math.floor(Math.random() * types.length)
			let input = inputComponent.createObject(root)
			input.source = types[index]
			model.append({ input: input })
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

	Connections {
		target: PageManager.navBar || null

		function onCurrentUrlChanged() {
			if (PageManager.navBar.currentUrl !== "qrc:/pages/OverviewPage.qml") {
				root._populateModel()
			}
		}
	}
}
