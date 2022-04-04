/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "../data" as DBusData

Item {
	id: root

	readonly property var tankTypes: [
		DBusData.Tanks.TankType.Fuel,
		DBusData.Tanks.TankType.FreshWater,
		DBusData.Tanks.TankType.WasteWater,
		DBusData.Tanks.TankType.LiveWell,
		DBusData.Tanks.TankType.Oil,
		DBusData.Tanks.TankType.BlackWater,
		DBusData.Tanks.TankType.Gasoline
	]

	readonly property ListModel fuelTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.Fuel
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "Fuel"
	}
	readonly property ListModel freshWaterTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.FreshWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "FreshWater"
	}
	readonly property ListModel wasteWaterTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.WasteWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "WasteWater"
	}
	readonly property ListModel liveWellTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.LiveWell
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "LiveWell"
	}
	readonly property ListModel oilTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.Oil
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "Oil"
	}
	readonly property ListModel blackWaterTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.BlackWater
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "BlackWater"
	}
	readonly property ListModel gasolineTanks: ListModel {
		readonly property int type: DBusData.Tanks.TankType.Gasoline
		property real totalCapacity
		property real totalRemaining
		property int unit: Units.PhysicalQuantity.Liters
		objectName: "Gasoline"
	}

	readonly property int totalTankCount: fuelTanks.count
			+ freshWaterTanks.count
			+ wasteWaterTanks.count
			+ liveWellTanks.count
			+ oilTanks.count
			+ blackWaterTanks.count
			+ gasolineTanks.count

	function tankModel(type) {
		switch (type) {
		case DBusData.Tanks.TankType.Fuel:
			return fuelTanks
		case DBusData.Tanks.TankType.FreshWater:
			return freshWaterTanks
		case DBusData.Tanks.TankType.WasteWater:
			return wasteWaterTanks
		case DBusData.Tanks.TankType.LiveWell:
			return liveWellTanks
		case DBusData.Tanks.TankType.Oil:
			return oilTanks
		case DBusData.Tanks.TankType.BlackWater:
			return blackWaterTanks
		case DBusData.Tanks.TankType.Gasoline:
			return gasolineTanks
		}
		console.warn("Unknown tank type", type)
		return null
	}

	function populate() {
		clearModels()

		// Occasionally simulate what it looks like with only the battery
		const batteryOnly = Math.random() < 0.1
		if (batteryOnly) {
			return
		}

		// Add 3 tanks of random types
		const maxTankType = DBusData.Tanks.TankType.Gasoline
		for (let i = 0; i < 3; ++i) {
			const tankType = Math.floor(Math.random() * maxTankType + 1)
			const level = Math.random()
			const capacity = 1000
			var tankData = {
				type: tankType,
				level: level * 100,
				remaining: capacity * level,
				capacity: capacity
			}
			addTank(tankData)
		}
	}

	function clearModels() {
		for (let i = 0; i < tankTypes.length; ++i) {
			tankModel(tankTypes[i]).clear()
		}
	}

	function addTank(data) {
		const model = tankModel(data.type)
		model.append({'tank': data })
		model.totalCapacity += data.capacity
		model.totalRemaining += data.remaining
	}

	function removeTank(tankType, tankIndex) {
		const model = tankModel(tankType)
		const data = model.get(tankIndex)
		if (!data) {
			console.warn("Invalid tank index", tankIndex, "for tank", model, "with", model.count, "items")
			return
		}
		model.totalCapacity -= data.tank.capacity
		model.totalRemaining -= data.tank.remaining
		model.remove(tankIndex)
	}

	function updateTank(index, data) {
		const model = tankModel(data.type)
		model.set(index, {"tank": data})

		let totalCapacity = 0
		let totalRemaining = 0
		for (let i = 0; i < model.count; ++i) {
			const props = model.get(i).tank
			if (!isNaN(props.capacity)) {
				totalCapacity += props.capacity
			}
			if (!isNaN(props.remaining)) {
				totalRemaining += props.remaining
			}
		}
		model.totalCapacity = totalCapacity
		model.totalRemaining = totalRemaining
	}

	Timer {
		running: true
		interval: 5000
		repeat: true
		onTriggered: {
			for (let i = 0; i < tankTypes.length; ++i) {
				const model = tankModel(tankTypes[i])
				for (let j = 0; j < model.count; ++j) {
					let properties = model.get(j).tank
					const randomLevel = Math.random()
					properties.level = randomLevel * 100
					properties.remaining = properties.capacity * randomLevel
					root.updateTank(j, properties)
				}
			}
		}
	}

	Timer {
		running: true
		interval: 20 * 1000
		repeat: true
		onTriggered: {
			let model
			if (Math.random() > 0.5) {
				// add a tank
				model = tankModel(Math.floor(Math.random() * tankTypes.length))
				const randomLevel = Math.random()
				var tank = {
					type: model.type,
					level: randomLevel * 100,
					capacity: 1000,
					remaining: 1000 * randomLevel,
				}
				root.addTank(tank)
			} else {
				// remove a tank
				for (let i = 0; i < tankTypes.length; ++i) {
					model = tankModel(tankTypes[i])
					if (model.count > 0) {
						const index = Math.floor(Math.random(model.count))
						root.removeTank(tankTypes[i], index)
						break
					}
				}
			}
		}
	}
}
