/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property int mockDeviceCount

	function populate() {
		Global.solarChargers.reset()

		// Add 4 chargers, each with an increasing number of trackers (max 4 trackers)
		const chargerCount = 4
		for (let i = 0; i < chargerCount; ++i) {
			const chargerObj = chargerComponent.createObject(root)
			chargerObj.initTrackers(i + 1)
		}
	}

	property Component chargerComponent: Component {
		SolarCharger {
			id: solarCharger

			function randomizeMeasurments() {
				/*
				1) a solar charger with one tracker has 3 paths:
				/Pv/V
				/Yield/Power
				/MppOperationMode

				2) a solar charger with two trackers has 8 paths:
				/Pv/0/V
				/Pv/0/P
				/Pv/0/MppOperationMode
				/Pv/1/V
				/Pv/1/P
				/Pv/1/MppOperationMode
				/Yield Power
				/MppOperationMode
				*/

				let totalPower = 0
				if (_trackerCount.value > 1) {
					for (let i = 0; i < _trackerCount.value; ++i) {
						const p = Math.random() * 100
						const trackerUid = serviceUid + "/Pv/" + i
						Global.mockDataSimulator.setMockValue(trackerUid + "/V", 90 + (Math.random() * 10))
						Global.mockDataSimulator.setMockValue(trackerUid + "/P", p)
						totalPower += p
					}
				} else {
					Global.mockDataSimulator.setMockValue(serviceUid + "/Pv/V", 90 + (Math.random() * 10))
					totalPower = Math.random() * 100
				}
				Global.mockDataSimulator.setMockValue(serviceUid + "/Yield/Power", totalPower)
			}

			function initTrackers(trackerCount) {
				Global.mockDataSimulator.setMockValue(serviceUid + "/NrOfTrackers", trackerCount)
				let trackerIndex = 0

				// Sometimes trackers have names. If available, they should show up in the UI.
				if (trackerCount > 1 && Math.random() < 0.5) {
					const charCode = 'A'.charCodeAt(0)
					for (trackerIndex = 0; trackerIndex < trackerCount; ++trackerIndex) {
						const nextTrackerName = "Tracker %1".arg(String.fromCharCode(charCode + trackerIndex))
						Global.mockDataSimulator.setMockValue(serviceUid + "/Pv/" + trackerIndex + "/Name", nextTrackerName)
					}
				}

				randomizeMeasurments()

				// Initialize history values
				Global.mockDataSimulator.setMockValue(serviceUid + "/History/Overall/DaysAvailable", 30)
				for (let day = 0; day < 31; ++day) {
					let dayTotals = []
					const dayOverallHistoryUid = serviceUid + "/History/Daily/" + day
					for (trackerIndex = 0; trackerIndex < trackerCount; ++trackerIndex) {
						// yield/power/voltage
						let yieldKwh = ((day + 1) + trackerIndex) * 0.01
						const maxPower = (day + 1 + trackerIndex)
						const maxPvVoltage = maxPower / 10

						// time in float/abs/bulk
						const timeSample = day + 1 + trackerIndex

						// battery
						const batteryVoltage = day + 1 + trackerIndex

						let data
						let historyUid = ""
						if (trackerCount > 1) {
							historyUid = serviceUid + "/History/Daily/" + day + "/Pv/" + trackerIndex
							data = {
								"Yield": yieldKwh * 10,
								"MaxPower": maxPower * 10,
								"MaxVoltage": maxPvVoltage * 10,
							}
						} else {
							// If only 1 tracker, add to overall history instead
							historyUid = dayOverallHistoryUid
							data = {
								"Yield": yieldKwh * 10,
								"MaxPower": maxPower * 10,
								"MaxPvVoltage": maxPvVoltage * 10,
								"TimeInBulk": timeSample,
								"TimeInAbsorption": timeSample * 2,
								"TimeInFloat": timeSample * 3,
								"MinBatteryVoltage": batteryVoltage,
								"MaxBatteryVoltage": batteryVoltage * 2,
								"MaxBatteryCurrent": batteryVoltage * 1.5
							}
						}

						for (const dataProperty in data) {
							Global.mockDataSimulator.setMockValue(historyUid + "/" + dataProperty, data[dataProperty])
							const currentValue = dayTotals[dataProperty] || 0
							const newValue = data[dataProperty]
							if (dataProperty.startsWith("Min")) {
								dayTotals[dataProperty] = Math.min(currentValue, newValue)
							} else if (dataProperty.startsWith("Max")) {
								dayTotals[dataProperty] = Math.max(currentValue, newValue)
							} else {
								dayTotals[dataProperty] = currentValue + newValue
							}
						}
					}

					if (trackerCount > 1) {
						// Update overall history for the day
						const overallProperties = [
							"Yield", "MaxPower", "MaxPvVoltage",
							"TimeInBulk", "TimeInAbsorption", "TimeInFloat",
							"MinBatteryVoltage", "MaxBatteryVoltage", "MaxBatteryCurrent"
						]
						for (let i = 0; i < overallProperties.length; ++i) {
							const propertyName = overallProperties[i]
							const total = dayTotals[propertyName] || 0
							Global.mockDataSimulator.setMockValue(dayOverallHistoryUid + "/" + propertyName, total)
						}
					}

					root.setRandomErrors(dayOverallHistoryUid)
				}
			}

			//--- internal members below ---

			property Timer _trackerUpdates: Timer {
				running: Global.mockDataSimulator.timersActive
				repeat: true
				interval: 2000
				onTriggered: {
					solarCharger.randomizeMeasurments()
				}
			}

			// Set a non-empty uid to avoid bindings to empty serviceUid before Component.onCompleted is called
			serviceUid: "mock/com.victronenergy.dummy"

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.solarcharger.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_productName.setValue("SmartSolar Charger MPPT 100/50")
				_productId.setValue(123)
				_customName.setValue("My Solar Charger " + deviceInstanceNum)
				_state.setValue(VenusOS.SolarCharger_State_ExternalControl)
				_errorCode.setValue(0)
				root.setRandomErrors(serviceUid + "/History/Overall")
			}
		}
	}

	function setRandomErrors(prefix) {
		for (let i = 0; i < 4; ++i) {
			const errorCode = Math.floor(Math.random() * 4)
			Global.mockDataSimulator.setMockValue(prefix + "/LastError" + (i + 1), errorCode)
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetSolarRequested(config) {
			Global.solarChargers.reset()

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {
					const chargerObj = chargerComponent.createObject(root)
					chargerObj.initTrackers(i + 1)
					if (config.chargers[i].power !== undefined) {
						chargerObj._totalPower.setValue(config.chargers[i].power)
					}
				}
			}
		}
	}

	property var _createdObjects: []

	Component.onCompleted: {
		populate()
	}
}
