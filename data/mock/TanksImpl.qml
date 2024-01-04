/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

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
			const tankObj = tankComponent.createObject(root, {
				type: tankType,
				temperature: Math.random() * 100,
				level: level * 100,
				remaining: capacity * level,
				capacity: capacity
			})
			Global.tanks.addTank(tankObj)
			_createdObjects.push(tankObj)
		}
	}

	property Component tankComponent: Component {
		MockDevice {
			property int type
			property int status: VenusOS.Tank_Status_Ok
			property real temperature
			property real level
			property real remaining
			property real capacity

			serviceUid: "mock/com.victronenergy.tank.ttyUSB" + deviceInstance
			name: "Tank" + deviceInstance
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
					let props = config[i]
					if (props.remaining === undefined) {
						props.remaining = props.capacity * (props.level / 100)
					}
					const tankObj = tankComponent.createObject(root, props)
					Global.tanks.addTank(tankObj)
					_createdObjects.push(tankObj)
				}
			}
		}
	}

	property Timer randomizeTankLevels: Timer {
		running: Global.mockDataSimulator.timersActive
		interval: 5000
		repeat: true
		onTriggered: {
			for (let i = 0; i < Global.tanks.tankTypes.length; ++i) {
				const model = Global.tanks.tankModel(Global.tanks.tankTypes[i])
				for (let j = 0; j < model.count; ++j) {
					let tank = model.deviceAt(j)
					const randomLevel = Math.random()
					tank.level = randomLevel * 100
					tank.remaining = tank.capacity * randomLevel
					Global.tanks.updateTankModelTotals(tank.type)
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
				const tankObj = tankComponent.createObject(root, {
					type: model.type,
					temperature: Math.random() * 100,
					level: randomLevel * 100,
					capacity: capacity,
					remaining: capacity * randomLevel,
				})
				Global.tanks.addTank(tankObj)
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
