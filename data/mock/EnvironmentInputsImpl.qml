/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	function populate() {
		const inputCount = _rand(1, 8)
		for (let i = 0; i < inputCount; ++i) {
			const inputObj = inputComponent.createObject(root, {
				name: "Sensor " + (i + 1),
				temperature_celsius: _rand(Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue,
						Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue),
				humidity: _rand(Theme.geometry.levelsPage.environment.humidityGauge.minimumValue,
						Theme.geometry.levelsPage.environment.humidityGauge.maximumValue)
			})
			Global.environmentInputs.addInput(inputObj)
		}
	}

	function _rand(min, max) {
		const range = (max - min) + 1
		return (Math.random() * range) + min
	}

	property int _objectId
	property Component inputComponent: Component {
		MockDevice {
			property real temperature_celsius
			property real humidity

			name: "EnvironmentInput" + deviceInstance.value
			Component.onCompleted: deviceInstance.value = root._objectId++
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetEnvironmentInputsRequested(config) {
			Global.environmentInputs.model.clear()

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					const inputObj = inputComponent.createObject(root, config[i])
					Global.environmentInputs.addInput(inputObj)
				}
			}
		}
	}

	property Instantiator inputObjects: Instantiator {
		model: Global.environmentInputs.model

		delegate: Timer {
			running: Global.mockDataSimulator.timersActive
			repeat: true
			interval: 10 * 1000
			onTriggered: {
				let data = Global.environmentInputs.model.get(model.index)
				data.temperature_celsius = root._rand(Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue,
						Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue)
				if (!isNaN(model.humidity)) {
					data.humidity = root._rand(Theme.geometry.levelsPage.environment.humidityGauge.minimumValue,
							Theme.geometry.levelsPage.environment.humidityGauge.maximumValue)
				}
				Global.environmentInputs.model.set(model.index, data)
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
