/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "common"

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

	readonly property DeviceModel fuelTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Fuel
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "Fuel"
	}
	readonly property DeviceModel freshWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "FreshWater"
	}
	readonly property DeviceModel wasteWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "WasteWater"
	}
	readonly property DeviceModel liveWellTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "LiveWell"
	}
	readonly property DeviceModel oilTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "Oil"
	}
	readonly property DeviceModel blackWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
		objectName: "BlackWater"
	}
	readonly property DeviceModel gasolineTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
		objectProperty: "tank"
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

	function addTank(tank) {
		const model = tankModel(tank.type)
		if (!model) {
			console.warn("addTank(): Unknown tank type", tank.type)
			return false
		}
		model.addObject(tank)
		updateTankModelTotals(tank.type)
		return true
	}

	function removeTank(tank) {
		const model = tankModel(tank.type)
		if (!model) {
			console.warn("removeTank(): Unknown tank type", tank.type)
			return
		}
		if (model.removeObject(tank.serviceUid)) {
			updateTankModelTotals(tank.type)
			return true
		}
		return false
	}

	function reset() {
		for (let i = 0; i < tankTypes.length; ++i) {
			tankModel(tankTypes[i]).clear()
		}
	}

	Component.onCompleted: Global.tanks = root
}
