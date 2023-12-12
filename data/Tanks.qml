/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	readonly property var tankTypes: [
		Enums.Tank_Type_Fuel,
		Enums.Tank_Type_FreshWater,
		Enums.Tank_Type_WasteWater,
		Enums.Tank_Type_LiveWell,
		Enums.Tank_Type_Oil,
		Enums.Tank_Type_BlackWater,
		Enums.Tank_Type_Gasoline,
		Enums.Tank_Type_Diesel,
		Enums.Tank_Type_LPG,
		Enums.Tank_Type_LNG,
		Enums.Tank_Type_HydraulicOil,
		Enums.Tank_Type_RawWater
	]

	readonly property var allTankModels: tankTypes.map(function(tankType) {
		return root.tankModel(tankType)
	})

	readonly property DeviceModel fuelTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_Fuel
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Fuel"
	}
	readonly property DeviceModel freshWaterTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-FreshWater"
	}
	readonly property DeviceModel wasteWaterTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-WasteWater"
	}
	readonly property DeviceModel liveWellTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LiveWell"
	}
	readonly property DeviceModel oilTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Oil"
	}
	readonly property DeviceModel blackWaterTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-BlackWater"
	}
	readonly property DeviceModel gasolineTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Gasoline"
	}
	readonly property DeviceModel dieselTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_Diesel
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Diesel"
	}
	readonly property DeviceModel lpgTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_LPG
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LPG"
	}
	readonly property DeviceModel lngTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_LNG
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LNG"
	}
	readonly property DeviceModel hydraulicOilTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_HydraulicOil
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-HydraulicOil"
	}
	readonly property DeviceModel rawWaterTanks: DeviceModel {
		readonly property int type: Enums.Tank_Type_RawWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-RawWater"
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
		case Enums.Tank_Type_Fuel:
			return fuelTanks
		case Enums.Tank_Type_FreshWater:
			return freshWaterTanks
		case Enums.Tank_Type_WasteWater:
			return wasteWaterTanks
		case Enums.Tank_Type_LiveWell:
			return liveWellTanks
		case Enums.Tank_Type_Oil:
			return oilTanks
		case Enums.Tank_Type_BlackWater:
			return blackWaterTanks
		case Enums.Tank_Type_Gasoline:
			return gasolineTanks
		case Enums.Tank_Type_Diesel:
			return dieselTanks
		case Enums.Tank_Type_LPG:
			return lpgTanks
		case Enums.Tank_Type_LNG:
			return lngTanks
		case Enums.Tank_Type_HydraulicOil:
			return hydraulicOilTanks
		case Enums.Tank_Type_RawWater:
			return rawWaterTanks
		}
		console.warn("tankModel(): Unknown tank type", type)
		return null
	}

	function statusToText(status) {
		switch (status) {
		case Enums.Tank_Status_Ok:
			return CommonWords.ok
		case Enums.Tank_Status_Disconnected:
			return CommonWords.disconnected
		case Enums.Tank_Status_ShortCircuited:
			//% "Short circuited"
			return qsTrId("tank_status_short_circuited")
		case Enums.Tank_Status_ReversePolarity:
			//% "Reverse polarity"
			return qsTrId("tank_status_reverse_polarity")
		case Enums.Tank_Status_Unknown:
			return CommonWords.unknown_status
		case Enums.Tank_Status_Error:
			return CommonWords.error
		default:
			return ""
		}
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
