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

	readonly property TankModel fuelTanks: TankModel {
		type: VenusOS.Tank_Type_Fuel
		modelId: "tanks-Fuel"
	}
	readonly property TankModel freshWaterTanks: TankModel {
		type: VenusOS.Tank_Type_FreshWater
		modelId: "tanks-FreshWater"
	}
	readonly property TankModel wasteWaterTanks: TankModel {
		type: VenusOS.Tank_Type_WasteWater
		modelId: "tanks-WasteWater"
	}
	readonly property TankModel liveWellTanks: TankModel {
		type: VenusOS.Tank_Type_LiveWell
		modelId: "tanks-LiveWell"
	}
	readonly property TankModel oilTanks: TankModel {
		type: VenusOS.Tank_Type_Oil
		modelId: "tanks-Oil"
	}
	readonly property TankModel blackWaterTanks: TankModel {
		type: VenusOS.Tank_Type_BlackWater
		modelId: "tanks-BlackWater"
	}
	readonly property TankModel gasolineTanks: TankModel {
		type: VenusOS.Tank_Type_Gasoline
		modelId: "tanks-Gasoline"
	}
	readonly property TankModel dieselTanks: TankModel {
		type: VenusOS.Tank_Type_Diesel
		modelId: "tanks-Diesel"
	}
	readonly property TankModel lpgTanks: TankModel {
		type: VenusOS.Tank_Type_LPG
		modelId: "tanks-LPG"
	}
	readonly property TankModel lngTanks: TankModel {
		type: VenusOS.Tank_Type_LNG
		modelId: "tanks-LNG"
	}
	readonly property TankModel hydraulicOilTanks: TankModel {
		type: VenusOS.Tank_Type_HydraulicOil
		modelId: "tanks-HydraulicOil"
	}
	readonly property TankModel rawWaterTanks: TankModel {
		type: VenusOS.Tank_Type_RawWater
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
		case VenusOS.Tank_Status_Open_Circuit:
			return CommonWords.open_circuit
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

	function reset() {
		for (let i = 0; i < tankTypes.length; ++i) {
			tankModel(tankTypes[i]).clear()
		}
	}

	Component.onCompleted: Global.tanks = root
}
