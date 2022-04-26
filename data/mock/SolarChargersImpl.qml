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

			const trackerObj = trackerComponent.createObject(root, {
				acPower: chargerAcPower,
				dcPower: chargerDcPower
			})
			Global.solarChargers.addTracker(trackerObj)
		}

		Global.solarChargers.yieldHistory = [13400, 18500, 16200, 12100, 9300, 6600, 3200, 1040, 4400, 8800, 9300, 6600, 3200]
		for (var historyIndex in Global.solarChargers.yieldHistory) {
			Utils.updateMaximumValue("dailySolarYield", Global.solarChargers.yieldHistory[historyIndex])
		}
	}

	property Component trackerComponent: Component {
		QtObject {
			property real acPower
			property real dcPower
		}
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetSolarChargersRequested(config) {
			Global.solarChargers.reset()

			if (config && config.trackers) {
				Global.solarChargers.acPower = 0
				Global.solarChargers.dcPower = 0

				for (let i = 0; i < config.trackers.length; ++i) {
					Global.solarChargers.acPower += config.trackers[i].acPower
					Global.solarChargers.dcPower += config.trackers[i].dcPower

					const trackerObj = trackerComponent.createObject(root, {
						acPower: config.trackers[i].acPower,
						dcPower: config.trackers[i].dcPower
					})
					Global.solarChargers.addTracker(trackerObj)
				}
			}
		}
	}

	Component.onCompleted: {
		populate()
	}
}
