/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Velib
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property ListModel model: ListModel {}

	function populate() {
		model.clear()
		const inputCount = _rand(1, 8)
		for (let i = 0; i < inputCount; ++i) {
			var data = {
				customName: "Sensor " + (i + 1),
				temperature: _rand(Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue,
						Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue),
				humidity: _rand(Theme.geometry.levelsPage.environment.humidityGauge.minimumValue,
						Theme.geometry.levelsPage.environment.humidityGauge.maximumValue)
			}
			addInput(data)
		}
	}

	function addInput(data) {
		model.append({'input': data })
	}

	function _rand(min, max) {
		const range = (max - min) + 1
		return (Math.random() * range) + min
	}

	Instantiator {
		model: root.model

		delegate: Timer {
			running: PageManager.navBar.currentUrl === "qrc:/pages/LevelsPage.qml"
			repeat: true
			interval: 10 * 1000
			onTriggered: {
				let data = root.model.get(model.index)
				data.temperature = root._rand(Theme.geometry.levelsPage.environment.temperatureGauge.minimumValue,
						Theme.geometry.levelsPage.environment.temperatureGauge.maximumValue)
				if (!isNaN(model.humidity)) {
					data.humidity = root._rand(Theme.geometry.levelsPage.environment.humidityGauge.minimumValue,
							Theme.geometry.levelsPage.environment.humidityGauge.maximumValue)
				}
				root.model.set(model.index, data)
			}
		}
	}
}
