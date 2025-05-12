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
		Global.solarDevices.model.clear()

		// Add 4 chargers, each with an increasing number of trackers (max 4 trackers)
		const chargerCount = 4
		for (let i = 0; i < chargerCount; ++i) {            
			const deviceInstanceNum = root.mockDeviceCount++
			const chargerObj = chargerComponent.createObject(root, {
				serviceUid: "mock/com.victronenergy.solarcharger.ttyUSB" + deviceInstanceNum,
				deviceInstance: deviceInstanceNum,
			})
			// MPPT chargers connected via VE.CAN only have 2 days of history; add a charger that
			// simulates this.
			const historyDaysAvailable = i === 0 ? 2 : 31
			chargerObj.setMockValue("/History/Overall/DaysAvailable", historyDaysAvailable)
			chargerObj.initTrackers(i + 1)
		}
	}

	property Component chargerComponent: Component {
		SolarDevice {
			id: solarCharger

			function setMockValue(path, value) {
				Global.mockDataSimulator.setMockValue(serviceUid + path, value)
			}

			function mockValue(path) {
				return Global.mockDataSimulator.mockValue(serviceUid + path)
			}

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
				const trackerCount = mockValue("/NrOfTrackers")
				if (trackerCount > 1) {
					for (let i = 0; i < trackerCount; ++i) {
						const p = Math.random() * 100
						const trackerUid = serviceUid + "/Pv/" + i
						Global.mockDataSimulator.setMockValue(trackerUid + "/V", 90 + (Math.random() * 10))
						Global.mockDataSimulator.setMockValue(trackerUid + "/P", p)
						totalPower += p
					}
				} else {
					setMockValue("/Pv/V", 90 + (Math.random() * 10))
					totalPower = Math.random() * 100
				}
				setMockValue("/Yield/Power", totalPower)
			}

			function initTrackers(trackerCount) {
				setMockValue("/NrOfTrackers", trackerCount)
				let trackerIndex = 0

				// Sometimes trackers have names. If available, they should show up in the UI,
				// unless /Enabled=0 for the tracker.
				if (trackerCount > 1 && Math.random() < 0.5) {
					const charCode = 'A'.charCodeAt(0)
					for (trackerIndex = 0; trackerIndex < trackerCount; ++trackerIndex) {
						if (trackerIndex === trackerCount - 1) {
							setMockValue("/Pv/" + trackerIndex + "/Enabled", 0)
							setMockValue("/Pv/" + trackerIndex + "/Name", "Disabled tracker, should not be in UI tracker lists")
						} else {
							const nextTrackerName = "Tracker %1".arg(String.fromCharCode(charCode + trackerIndex))
							setMockValue("/Pv/" + trackerIndex + "/Name", nextTrackerName)
						}
					}
				}

				randomizeMeasurments()

				// Initialize history values
				for (let day = 0; day < solarCharger.history.daysAvailable; ++day) {
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

			Component.onCompleted: {
				_deviceInstance.setValue(deviceInstance)
				_productName.setValue("SmartSolar Charger MPPT 100/50")
				_customName.setValue("My Solar Charger " + deviceInstance)
				setMockValue("/State", VenusOS.SolarCharger_State_ExternalControl)
				setMockValue("/ErrorCode", Math.random() < 0.4 ? Math.floor(Math.random() * 30) : 0)
				setMockValue("/History/Overall/DaysAvailable", 31)
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
			Global.solarDevices.model.clear()

			if (config && config.chargers) {
				for (let i = 0; i < config.chargers.length; ++i) {                    
					const deviceInstanceNum = root.mockDeviceCount++
					const chargerObj = chargerComponent.createObject(root, {
						serviceUid: "mock/com.victronenergy.solarcharger.ttyUSB" + deviceInstanceNum,
						deviceInstance: deviceInstanceNum,
					})
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
