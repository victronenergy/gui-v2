/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	function populate() {
		Global.solarChargers.acPower = 0
		Global.solarChargers.dcPower = 0

		const chargerCount = Math.floor(Math.random() * 4) + 1
		for (let i = 0; i < chargerCount; ++i) {
			// Randomly distribute the charger power to AC/DC output
			let chargerPower = 50 + Math.floor(Math.random() * 200)
			let chargerAcPower = Math.random() * chargerPower
			let chargerDcPower = chargerPower - chargerAcPower
			Global.solarChargers.acPower += chargerAcPower
			Global.solarChargers.dcPower += chargerDcPower

			const chargerObj = chargerComponent.createObject(root, {
				power: chargerPower,
			})
			// assume one tracker for now
			const trackerObj = chargerComponent.createObject(root, {
				power: chargerPower,
			})
			chargerObj.trackers.append({ solarTracker: trackerObj })
			Global.solarChargers.addCharger(chargerObj)
		}

		populateYieldHistory()
	}

	function populateYieldHistory() {
		Global.solarChargers.yieldHistory.clear()
		for (let day = 0; day < 30; day++) {
			const dailyYield = 50 + (Math.random() * 100)    // kwh
			if (day == 0) {
				Global.solarChargers.yieldHistory.maximum = dailyYield
			} else {
				Global.solarChargers.yieldHistory.maximum = Math.max(
						Global.solarChargers.yieldHistory.maximum, dailyYield)
			}
			Global.solarChargers.yieldHistory.setYield(day, dailyYield)
		}
	}

	property Component chargerComponent: Component {
		QtObject {
			property real power
			property real voltage

			property ListModel trackers: ListModel {}
		}
	}

	property Component trackerComponent: Component {
		QtObject {
			property real power
			property real voltage
		}
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetSolarChargersRequested(config) {
			Global.solarChargers.reset()

			if (config && config.chargers) {
				Global.solarChargers.acPower = 0
				Global.solarChargers.dcPower = 0

				for (let i = 0; i < config.chargers.length; ++i) {
					Global.solarChargers.acPower += config.chargers[i].acPower
					Global.solarChargers.dcPower += config.chargers[i].dcPower

					const chargerObj = chargerComponent.createObject(root, {
						power: config.chargers[i].acPower + config.chargers[i].dcPower
					})
					// assume one tracker for now
					const trackerObj = chargerComponent.createObject(root, {
						power: chargerObj.power,
					})
					chargerObj.trackers.append({ solarTracker: trackerObj })

					Global.solarChargers.addCharger(chargerObj)
				}

				populateYieldHistory()
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
