/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Gauges

QtObject {
	id: root

	property int mockDeviceCount

	function populate() {
		// Occasionally simulate what it looks like with only the battery
		const batteryOnly = Math.random() < 0.1
		if (batteryOnly) {
			return
		}

		// Add 3 tanks of random types
		const maxTankType = VenusOS.Tank_Type_RawWater
		for (let i = 0; i < 3; ++i) {
			const tankType = Math.floor(Math.random() * maxTankType + 1)
			const level = Math.random()
			const capacity = 1  // m3
			const tankProperties = {
				type: tankType,
				temperature: Math.random() * 100,
				level: level * 100,
				remaining: capacity * level,
				capacity: capacity
			}
			addTank(tankProperties)
		}
	}

	function addTank(properties) {
		if (properties.remaining === undefined) {
			properties.remaining = properties.capacity * (properties.level / 100)
		}
		const tankObj = tankComponent.createObject(root)
		_createdObjects.push(tankObj)
		for (var p in properties) {
			tankObj["_" + p].setValue(properties[p])
		}
	}

	property Component tankComponent: Component {
		Tank {
			id: tank

			onTypeChanged: {
				if (type >= 0) {
					_customName.setValue(Gauges.tankProperties(type).name)
				}
			}

			Component.onCompleted: {
				const deviceInstanceNum = root.mockDeviceCount++
				serviceUid = "mock/com.victronenergy.tank.ttyUSB" + deviceInstanceNum
				_deviceInstance.setValue(deviceInstanceNum)
				_productName.setValue("Generic Tank Input")
				_status.setValue(VenusOS.Tank_Status_Ok)
			}

			property Timer randomizeTankLevels: Timer {
				running: Global.mockDataSimulator.timersActive
				interval: 5000
				repeat: true
				onTriggered: {
					const randomLevel = Math.random()
					tank._level.setValue(randomLevel * 100)
					tank._remaining.setValue(tank.capacity * randomLevel)
				}
			}
		}
	}

	property Connections mockConn: Connections {
		target: Global.mockDataSimulator || null

		function onSetTanksRequested(config) {
			Global.tanks.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					root.addTank(config[i])
				}
			}
		}
	}


	property Timer randomizeTanks: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 20 * 1000
		repeat: true
		onTriggered: {
			let model
			if (Math.random() > 0.5) {
				// add a tank
				model = Global.tanks.tankModel(Math.floor(Math.random() * Global.tanks.tankTypes.length))
				const randomLevel = Math.random()
				const capacity = 1  // m3
				const tankProperties = {
					type: model.type,
					temperature: Math.random() * 100,
					level: randomLevel * 100,
					capacity: capacity,
					remaining: capacity * randomLevel,
				}
				root.addTank(tankProperties)
			} else {
				// remove a tank
				for (let i = 0; i < Global.tanks.tankTypes.length; ++i) {
					model = Global.tanks.tankModel(Global.tanks.tankTypes[i])
					if (model.count > 0) {
						const index = Math.floor(Math.random(model.count))
						Global.tanks.removeTank(model.deviceAt(index))
						break
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
