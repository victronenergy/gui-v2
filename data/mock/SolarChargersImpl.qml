/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

QtObject {
	id: root

	function populate() {
		Global.solarChargers.reset()
		Global.solarChargers.acPower = 0
		Global.solarChargers.dcPower = 0
		Global.solarChargers.acCurrent = 0
		Global.solarChargers.dcCurrent = 0

		const chargerCount = Math.floor(Math.random() * 4) + 1
		for (let i = 0; i < chargerCount; ++i) {
			// Randomly distribute the charger power to AC/DC output
			let chargerPower = 50 + Math.floor(Math.random() * 200)
			let chargerAcPower = Math.random() * chargerPower
			let chargerDcPower = chargerPower - chargerAcPower
			Global.solarChargers.acPower += chargerAcPower
			Global.solarChargers.dcPower += chargerDcPower

			let chargerAcCurrent = chargerAcPower * 0.01
			let chargerDcCurrent = chargerDcPower * 0.01
			Global.solarChargers.acCurrent += chargerAcCurrent
			Global.solarChargers.dcCurrent += chargerDcCurrent

			const chargerObj = chargerComponent.createObject(root, {
				power: chargerPower,
				voltage: 10 + Math.random() * 5
			})
			_createdObjects.push(chargerObj)

			Global.solarChargers.addCharger(chargerObj)
		}
	}

	property Component chargerComponent: Component {
		QtObject {
			property real power
			property real voltage
			readonly property bool yieldHistoriesReady: _completedCount > 0
					&& yieldHistories.count === _completedCount

			onYieldHistoriesReadyChanged: {
				if (yieldHistoriesReady) {
					Qt.callLater(Global.solarChargers.initializeYieldHistory)
				}
			}

			property int _completedCount

			readonly property Instantiator yieldHistories: Instantiator {
				model: 31
				delegate: QtObject {
					readonly property int yieldKwH: 50 + (Math.random() * 100)    // kwh
					Component.onCompleted: _completedCount++
				}
			}
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSolarChargersRequested(config) {
			Global.solarChargers.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					if (config.chargers[i].acPower) {
						if (isNaN(Global.solarChargers.acPower)) {
							Global.solarChargers.acPower = 0
							Global.solarChargers.acCurrent = 0
						}
						Global.solarChargers.acPower += config.chargers[i].acPower
						Global.solarChargers.acCurrent += config.chargers[i].acPower * 0.01
					}
					if (config.chargers[i].dcPower) {
						if (isNaN(Global.solarChargers.dcPower)) {
							Global.solarChargers.dcPower = 0
							Global.solarChargers.dcCurrent = 0
						}
						Global.solarChargers.dcPower += config.chargers[i].dcPower
						Global.solarChargers.dcCurrent += config.chargers[i].dcPower * 0.01
					}

					const chargerObj = chargerComponent.createObject(root, {
						power: (config.chargers[i].acPower || 0) + (config.chargers[i].dcPower || 0),
						voltage: 10 + Math.random() * 5
					})
					_createdObjects.push(chargerObj)

					Global.solarChargers.addCharger(chargerObj)
				}
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
