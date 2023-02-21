/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var tankTypes: [
		VenusOS.Tank_Type_Fuel,
		VenusOS.Tank_Type_FreshWater,
		VenusOS.Tank_Type_WasteWater,
		VenusOS.Tank_Type_LiveWell,
		VenusOS.Tank_Type_Oil,
		VenusOS.Tank_Type_BlackWater,
		VenusOS.Tank_Type_Gasoline
	]

	readonly property ListModel fuelTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Fuel
		property real totalCapacity
		property real totalRemaining
		objectName: "Fuel"
	}
	readonly property ListModel freshWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		objectName: "FreshWater"
	}
	readonly property ListModel wasteWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		objectName: "WasteWater"
	}
	readonly property ListModel liveWellTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		objectName: "LiveWell"
	}
	readonly property ListModel oilTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		objectName: "Oil"
	}
	readonly property ListModel blackWaterTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		objectName: "BlackWater"
	}
	readonly property ListModel gasolineTanks: ListModel {
		readonly property int type: VenusOS.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
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
		case VenusOS.Tank_Type_Fuel:
			return fuelTanks
		case VenusOS.Tank_Type_FreshWater:
			return freshWaterTanks
		case VenusOS.Tank_Type_WasteWater:
			return wasteWaterTanks
		case VenusOS.Tank_Type_LiveWell:
			return liveWellTanks
		case VenusOS.Tank_Type_Oil:
			return oilTanks
		case VenusOS.Tank_Type_BlackWater:
			return blackWaterTanks
		case VenusOS.Tank_Type_Gasoline:
			return gasolineTanks
		}
		console.warn("tankModel(): Unknown tank type", type)
		return null
	}

	function updateTankModelTotals(tankType) {
		const model = tankModel(tankType)
		if (!model) {
			console.warn("updateTankModelTotals(): Unknown tank type", tankType)
			return
		}
		let totalRemaining = NaN
		let totalCapacity = NaN
		for (let i = 0; i < model.count; ++i) {
			const tank = model.get(i).tank
			if (!isNaN(tank.remaining)) {
				if (isNaN(totalRemaining)) {
					totalRemaining = 0
				}
				totalRemaining += tank.remaining
			}
			if (!isNaN(tank.capacity)) {
				if (isNaN(totalCapacity)) {
					totalCapacity = 0
				}
				totalCapacity += tank.capacity
			}
		}
		model.totalRemaining = totalRemaining
		model.totalCapacity = totalCapacity
	}

	function findTank(model, data) {
		for (let i = 0; i < model.count; ++i) {
			if (model.get(i).tank === data) {
				return i
			}
		}
		return -1
	}

	function addTank(data) {
		const model = tankModel(data.type)
		if (!model) {
			console.warn("addTank(): Unknown tank type", data.type)
			return
		}
		model.append({'tank': data })
		updateTankModelTotals(data.type)
	}

	function removeTank(model, data) {
		if (!model) {
			console.warn("removeTank(): no model specified")
			return
		}
		const index = findTank(model, data)
		if (index < 0 || index >= model.count) {
			console.warn("removeTank(): cannot find tank", data.name)
			return
		}
		model.remove(index)
		updateTankModelTotals(data.type)
	}

	function setTankData(index, data) {
		const model = tankModel(data.type)
		if (!model) {
			console.warn("setTankData(): Unknown tank type", data.type)
			return
		}
		model.set(index, {"tank": data})
		updateTankModelTotals(data.type)
	}

	function reset() {
		for (let i = 0; i < tankTypes.length; ++i) {
			tankModel(tankTypes[i]).clear()
		}
	}

	Component.onCompleted: Global.tanks = root
}
