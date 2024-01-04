/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
				temperature_celsius: _rand(Theme.geometry_levelsPage_environment_temperatureGauge_minimumValue,
						Theme.geometry_levelsPage_environment_temperatureGauge_maximumValue),
				humidity: _rand(Theme.geometry_levelsPage_environment_humidityGauge_minimumValue,
						Theme.geometry_levelsPage_environment_humidityGauge_maximumValue)
			})
			Global.environmentInputs.addInput(inputObj)
		}
	}

	function _rand(min, max) {
		const range = (max - min) + 1
		return (Math.random() * range) + min
	}

	property Component inputComponent: Component {
		MockDevice {
			property real temperature_celsius
			property real humidity

			serviceUid: "mock/com.victronenergy.temperature.ttyUSB" + deviceInstance
			name: "EnvironmentInput" + deviceInstance
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
				const input = model.device
				input.temperature_celsius = root._rand(Theme.geometry_levelsPage_environment_temperatureGauge_minimumValue,
						Theme.geometry_levelsPage_environment_temperatureGauge_maximumValue)
				if (!isNaN(input.humidity)) {
					input.humidity = root._rand(Theme.geometry_levelsPage_environment_humidityGauge_minimumValue,
							Theme.geometry_levelsPage_environment_humidityGauge_maximumValue)
				}
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
