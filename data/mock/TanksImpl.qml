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
	property var _createdObjects: []

	function populate() {
		if (!Global.mockDataSimulator.levelsEnabled) {
			return
		}

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
		const deviceInstanceNum = mockDeviceCount++
		const tankObj = tankComponent.createObject(root, {
			serviceUid: "mock/com.victronenergy.tank.ttyUSB" + deviceInstanceNum,
		})
		tankObj._device.deviceInstance = deviceInstanceNum
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
					_device._customName.setValue("Custom " + Gauges.tankProperties(type).name + " tank")
				}
			}

			Component.onCompleted: {
				_device._productName.setValue("Generic Tank Input")
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
			// Do not remove all objects in the model before adding the new ones, as Levels page
			// will disappear.
			const hasCreatedObjects = _createdObjects.length > 0
			while (_createdObjects.length > 1) {
				let obj = _createdObjects.pop()
				obj._device.deviceInstance = -1
				obj.destroy()
			}

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					root.addTank(config[i])
				}
			}

			if (hasCreatedObjects) {
				let lastObject = _createdObjects.shift()
				lastObject._device.deviceInstance = -1
				lastObject.destroy()
			}
		}
	}

	property Timer randomizeTanks: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 20 * 1000
		repeat: true
		onTriggered: {
			let model
			if (Math.random() > 0.5 || _createdObjects.length === 0) {
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
				const index = Math.floor(Math.random() * _createdObjects.length)
				_createdObjects[index]._device.deviceInstance = -1 // causes tank to remove itself from model
				_createdObjects.splice(index, 1)
			}
		}
	}

	property bool levelsEnabled: Global.mockDataSimulator.levelsEnabled
	onLevelsEnabledChanged: {
		if (levelsEnabled) {
			let model
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
			for (var i = 0; i < _createdObjects.length; ++i) {
				_createdObjects[i]._device.deviceInstance = -1 // causes tank to remove itself from model
			}

			_createdObjects = []
		}
	}

	Component.onCompleted: {
		populate()
	}
}
