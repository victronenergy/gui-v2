/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Utils

QtObject {
	id: root

	function populate() {
		Global.solarChargers.reset()

		// Add 4 chargers, each with an increasing number of trackers (max 4 trackers)
		const chargerCount = 4
		for (let i = 0; i < chargerCount; ++i) {
			let chargerPower = 50 + Math.floor(Math.random() * 200)
			const chargerObj = chargerComponent.createObject(root, {
				name: "My charger " + i,
				power: chargerPower,
				errorModel: createErrorModel(Math.floor(Math.random() * 4))
			})
			chargerObj.initTrackers(i + 1)
			_createdObjects.push(chargerObj)

			Global.solarChargers.addCharger(chargerObj)
		}
	}

	function createErrorModel(errorCount) {
		const errorCode = 1
		let errors = errorModelComponent.createObject(root)
		for (let errorIndex = 0; errorIndex < errorCount; ++errorIndex) {
			errors.append({'errorNumber': errorIndex + 1, errorCode})
		}
		return errors
	}

	property var errorModelComponent: Component {
		ListModel {}
	}

	property Component chargerComponent: Component {
		MockDevice {
			id: solarCharger

			property int state: VenusOS.SolarCharger_State_ExternalControl
			property int errorCode: -1
			readonly property ListModel trackers: ListModel {}
			property real power

			readonly property real batteryVoltage: 43.21
			readonly property real batteryCurrent: 63.2
			readonly property real batteryTemperature: 40

			readonly property bool relayValid: true
			readonly property bool relayOn: true

			property var errorModel

			signal yieldUpdatedForDay(day: int, solarCharger: var)

			function dailyHistory(day, trackerIndex) {
				if (trackerIndex !== undefined) {
					return _trackerHistory[day][trackerIndex]
				}
				let dayData = {}
				const properties = [
					"yieldKwh", "maxPower", "maxPvVoltage",
					"timeInBulk", "timeInAbsorption", "timeInFloat",
					"minBatteryVoltage", "maxBatteryVoltage", "maxBatteryCurrent"
				]
				// get the combined total (or min/max) for all trackers on this day
				for (let propIndex = 0; propIndex < properties.length; ++propIndex) {
					const propName = properties[propIndex]
					let values = []
					for (let tIndex = 0; tIndex < trackers.count; ++tIndex) {
						values.push(_trackerHistory[day][tIndex][propName])
					}
					let overallValue = 0
					if (propName.indexOf("min") === 0) {
						overallValue = values.reduce((a, b) => Math.min(a, b), Infinity);
					} else if (propName.indexOf("max") === 0) {
						overallValue = values.reduce((a, b) => Math.max(a, b), -Infinity);
					} else {
						overallValue = values.reduce((a, b) => a + b, 0);
					}
					dayData[propName] = overallValue
				}
				dayData.errorModel = createErrorModel(day % 4)
				return dayData
			}

			function initTrackers(trackerCount) {
				for (let i = 0; i < trackerCount; ++i) {
					const trackerName = "%1 (#%2)".arg(solarCharger.name).arg(i+1)
					let tracker = trackerComponent.createObject(root, {"name": trackerName})
					tracker.power = (i + 1) * 100
					trackers.append({"solarTracker": tracker })
				}

				for (let day = 0; day < 31; ++day) {
					let dayHistory = []
					for (let trackerIndex = 0; trackerIndex < trackers.count; ++trackerIndex) {
						// yield/power/voltage
						let yieldKwh = ((day + 1) + trackerIndex) * 0.01
						const maxPower = (day + 1 + trackerIndex)
						const maxPvVoltage = maxPower / 10

						// time in float/abs/bulk
						const timeSample = day + 1 + trackerIndex

						// battery
						const batteryVoltage = day + 1 + trackerIndex

						const data = {
							"yieldKwh": yieldKwh * 10,
							"maxPower": maxPower * 10,
							"maxPvVoltage": maxPvVoltage * 10,
							"timeInBulk": timeSample,
							"timeInAbsorption": timeSample * 2,
							"timeInFloat": timeSample * 3,
							"minBatteryVoltage": batteryVoltage,
							"maxBatteryVoltage": batteryVoltage * 2,
							"maxBatteryCurrent": batteryVoltage * 1.5
						}
						dayHistory.push(data)
					}
					_trackerHistory.push(dayHistory)
				}
			}

			//--- internal members below ---

			property var _trackerHistory: []

			property Timer _trackerUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 1000
				onTriggered: {
					const trackerIndex = Math.floor(Math.random() * trackers.count)
					const tracker = trackers.get(trackerIndex).solarTracker
					solarCharger.power -= tracker.power
					tracker.power += (1 + (Math.random() * 10))
					solarCharger.power += tracker.power
				}
			}

			serviceUid: "mock/com.victronenergy.solarcharger.ttyUSB" + deviceInstance
			name: "SolarCharger" + deviceInstance
		}
	}

	property var _historyComponent: Component {
		QtObject {
			property real yieldKwh
			property real maxPower
			property real maxPvVoltage

			property real timeInFloat
			property real timeInAbsorption
			property real timeInBulk

			property real minBatteryVoltage
			property real maxBatteryVoltage
			property real maxBatteryCurrent

			property var errorModel: createErrorModel()
		}
	}

	property Component trackerComponent: Component {
		QtObject {
			property real power: Math.random() * 10
			property real voltage: power / 5
			readonly property real current: isNaN(power) || isNaN(voltage) || voltage === 0 ? NaN : power / voltage
			property string name
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSolarRequested(config) {
			Global.solarChargers.reset()
			Global.system.solar.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					const chargerObj = chargerComponent.createObject(root, {
						power: config.chargers[i].power,
						errorModel: createErrorModel(Math.floor(Math.random() * 4))
					})
					chargerObj.initTrackers(Global.solarChargers.model.count + 1)
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
