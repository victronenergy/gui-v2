/*
** Copyright (C) 2022 Victron Energy B.V.
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
		const maxTankType = VenusOS.Tank_Type_Gasoline
		for (let i = 0; i < 3; ++i) {
			const tankType = Math.floor(Math.random() * maxTankType + 1)
			const level = Math.random()
			const capacity = 1  // m3
			const tankObj = tankComponent.createObject(root, {
				type: tankType,
				level: level * 100,
				remaining: capacity * level,
				capacity: capacity
			})
			Global.tanks.addTank(tankObj)
			_createdObjects.push(tankObj)
		}
	}

	property Component tankComponent: Component {
		QtObject {
			property int type
			property real level
			property real remaining
			property real capacity
		}
	}

	property Connections demoConn: Connections {
		target: Global.demoManager || null

		function onSetTanksRequested(config) {
			Global.tanks.reset()
			while (_createdObjects.length > 0) {
				_createdObjects.pop().destroy()
			}

			if (config) {
				for (let i = 0; i < config.length; ++i) {
					const tankObj = tankComponent.createObject(root, config[i])
					Global.tanks.addTank(tankObj)
					_createdObjects.push(tankObj)
				}
			}
		}
	}

	property Timer randomizeTankLevels: Timer {
		running: Global.demoManager.timersActive
		interval: 5000
		repeat: true
		onTriggered: {
			for (let i = 0; i < Global.tanks.tankTypes.length; ++i) {
				const model = Global.tanks.tankModel(Global.tanks.tankTypes[i])
				for (let j = 0; j < model.count; ++j) {
					let properties = model.get(j).tank
					const randomLevel = Math.random()
					properties.level = randomLevel * 100
					properties.remaining = properties.capacity * randomLevel
					Global.tanks.setTankData(j, properties)
				}
			}
		}
	}

	property Timer randomizeTanks: Timer {
		running: Global.demoManager.timersActive
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
						Global.tanks.removeTank(Global.tanks.tankTypes[i], index)
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
