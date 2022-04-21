/*
** Copyright (C) 2021 Victron Energy B.V.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	function statusFromRisingValue(value) {
		if (value >= 85) return Theme.Critical
		if (value >= 60) return Theme.Warning
		return Theme.Ok
	}

	function statusFromFallingValue(value) {
		if (value <= 15) return Theme.Critical
		if (value <= 40) return Theme.Warning
		return Theme.Ok
	}

	function getValueStatus(value, valueType) {
		if (valueType === Enums.Gauges_ValueType_RisingPercentage) {
			return statusFromRisingValue(value)
		}
		if (valueType === Enums.Gauges_ValueType_FallingPercentage) {
			return statusFromFallingValue(value)
		}
		return Theme.Ok
	}

	function tankProperties(type) {
		switch (type) {
		case Enums.Tank_Type_Fuel:
			return {
				icon: "/images/fuel.svg",
				valueType: Enums.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.fuel.borderColor,
				//% "Fuel"
				name: qsTrId("tank_fuel")
			}
		case Enums.Tank_Type_FreshWater:
			return {
				icon: "/images/freshWater20x27.svg",
				valueType: Enums.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.freshWater.borderColor,
				//% "Fresh water"
				name: qsTrId("tank_fresh_water")
			}
		case Enums.Tank_Type_WasteWater:
			return {
				icon: "/images/wasteWater.svg",
				valueType: Enums.Gauges_ValueType_RisingPercentage,
				borderColor: Theme.color.levelsPage.wasteWater.borderColor,
				//% "Waste water"
				name: qsTrId("tank_waste_water")
			}
		case Enums.Tank_Type_LiveWell:
			return {
				icon: "/images/liveWell.svg",
				valueType: Enums.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.liveWell.borderColor,
				//% "Live well"
				name: qsTrId("tank_live_well")
			}
		case Enums.Tank_Type_Oil:
			return {
				icon: "/images/oil.svg",
				valueType: Enums.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.oil.borderColor,
				//% "Oil"
				name: qsTrId("tank_oil")
			}
		case Enums.Tank_Type_BlackWater:
			return {
				icon: "/images/blackWater.svg",
				valueType: Enums.Gauges_ValueType_RisingPercentage,
				borderColor: Theme.color.levelsPage.blackWater.borderColor,
				//% "Black water"
				name: qsTrId("tank_black_water")
			}
		case Enums.Tank_Type_Gasoline:
			return {
				icon: "/images/tank.svg", // same as "Fuel"
				valueType: Enums.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.gasoline.borderColor,
				//% "Gasoline"
				name: qsTrId("tank_gasoline")
			}
		}
		console.warn("Unknown tank type", type)
		return {}
	}
}
