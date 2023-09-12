/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
		modelId: "tanks-Fuel"
	}
	readonly property DeviceModel freshWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_FreshWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-FreshWater"
	}
	readonly property DeviceModel wasteWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_WasteWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-WasteWater"
	}
	readonly property DeviceModel liveWellTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LiveWell
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LiveWell"
	}
	readonly property DeviceModel oilTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Oil
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Oil"
	}
	readonly property DeviceModel blackWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_BlackWater
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-BlackWater"
	}
	readonly property DeviceModel gasolineTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Gasoline
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Gasoline"
	}
	readonly property DeviceModel dieselTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_Diesel
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-Diesel"
	}
	readonly property DeviceModel lpgTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LPG
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LPG"
	}
	readonly property DeviceModel lngTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_LNG
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-LNG"
	}
	readonly property DeviceModel hydraulicOilTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_HydraulicOil
		property real totalCapacity
		property real totalRemaining
		modelId: "tanks-HydraulicOil"
	}
	readonly property DeviceModel rawWaterTanks: DeviceModel {
		readonly property int type: VenusOS.Tank_Type_RawWater
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

	function statusToText(status) {
		switch (status) {
		case VenusOS.Tank_Status_Ok:
			return CommonWords.ok
		case VenusOS.Tank_Status_Disconnected:
			return CommonWords.disconnected
		case VenusOS.Tank_Status_ShortCircuited:
			//% "Short circuited"
			return qsTrId("tank_status_short_circuited")
		case VenusOS.Tank_Status_ReversePolarity:
			//% "Reverse polarity"
			return qsTrId("tank_status_reverse_polarity")
		case VenusOS.Tank_Status_Unknown:
			return CommonWords.unknown_status
		case VenusOS.Tank_Status_Error:
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
