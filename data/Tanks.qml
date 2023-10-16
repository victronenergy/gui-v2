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
		VenusOS.Tank_Type_Gasoline,
		VenusOS.Tank_Type_Diesel,
		VenusOS.Tank_Type_LPG,
		VenusOS.Tank_Type_LNG,
		VenusOS.Tank_Type_HydraulicOil,
		VenusOS.Tank_Type_RawWater
	]

	readonly property var allTankModels: tankTypes.map(function(tankType) {
		return root.tankModel(tankType)
	})

	readonly property DeviceModel fuelTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Fuel
		property real totalCapacity
		property real totalRemaining
		objectName: "Fuel"
	}
	readonly property DeviceModel freshWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		objectName: "FreshWater"
	}
	readonly property DeviceModel wasteWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		objectName: "WasteWater"
	}
	readonly property DeviceModel liveWellTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		objectName: "LiveWell"
	}
	readonly property DeviceModel oilTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		objectName: "Oil"
	}
	readonly property DeviceModel blackWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		objectName: "BlackWater"
	}
	readonly property DeviceModel gasolineTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
		objectName: "Gasoline"
	}
	readonly property DeviceModel dieselTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Diesel
		property real totalCapacity
		property real totalRemaining
		objectName: "Diesel"
	}
	readonly property DeviceModel lpgTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LPG
		property real totalCapacity
		property real totalRemaining
		objectName: "LPG"
	}
	readonly property DeviceModel lngTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LNG
		property real totalCapacity
		property real totalRemaining
		objectName: "LNG"
	}
	readonly property DeviceModel hydraulicOilTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_HydraulicOil
		property real totalCapacity
		property real totalRemaining
		objectName: "HydraulicOil"
	}
	readonly property DeviceModel rawWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_RawWater
		property real totalCapacity
		property real totalRemaining
		objectName: "RawWater"
	}

	readonly property int totalTankCount: fuelTanks.count
			+ freshWaterTanks.count
			+ wasteWaterTanks.count
			+ liveWellTanks.count
			+ oilTanks.count
			+ blackWaterTanks.count
			+ gasolineTanks.count
			+ dieselTanks.count
			+ lpgTanks.count
			+ lngTanks.count
			+ hydraulicOilTanks.count
			+ rawWaterTanks.count

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
		case VenusOS.Tank_Type_Diesel:
			return dieselTanks
		case VenusOS.Tank_Type_LPG:
			return lpgTanks
		case VenusOS.Tank_Type_LNG:
			return lngTanks
		case VenusOS.Tank_Type_HydraulicOil:
			return hydraulicOilTanks
		case VenusOS.Tank_Type_RawWater:
			return rawWaterTanks
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
			const tank = model.deviceAt(i)
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
		model.addDevice(tank)
		updateTankModelTotals(tank.type)
		return true
	}

	function removeTank(tank) {
		const model = tankModel(tank.type)
		if (!model) {
			console.warn("removeTank(): Unknown tank type", tank.type)
			return
		}
		if (model.removeDevice(tank.serviceUid)) {
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
