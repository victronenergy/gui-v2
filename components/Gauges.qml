/*
** Copyright (C) 2021 Victron Energy B.V.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {

	readonly property var gaugeTypes: [
		VenusOS.Tank_Type_Battery,
		VenusOS.Tank_Type_Fuel,
		VenusOS.Tank_Type_FreshWater,
		VenusOS.Tank_Type_WasteWater,
		VenusOS.Tank_Type_LiveWell,
		VenusOS.Tank_Type_Oil,
		VenusOS.Tank_Type_BlackWater,
		VenusOS.Tank_Type_Gasoline
	]

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
		if (valueType === VenusOS.Gauges_ValueType_RisingPercentage) {
			return statusFromRisingValue(value)
		}
		if (valueType === VenusOS.Gauges_ValueType_FallingPercentage) {
			return statusFromFallingValue(value)
		}
		return Theme.Ok
	}

	function tankProperties(type) {
		switch (type) {
		case VenusOS.Tank_Type_Battery:
			return {
				icon: "/images/battery.svg",
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.ok,
				//% "Battery"
				name: qsTrId("gauges_battery")
			}
		case VenusOS.Tank_Type_Fuel:
			return {
				icon: "/images/fuel.svg",
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.fuel.borderColor,
				//% "Fuel"
				name: qsTrId("gauges_fuel")
			}
		case VenusOS.Tank_Type_FreshWater:
			return {
				icon: "/images/freshWater20x27.svg",
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.freshWater.borderColor,
				//% "Fresh water"
				name: qsTrId("gauges_fresh_water")
			}
		case VenusOS.Tank_Type_WasteWater:
			return {
				icon: "/images/wasteWater.svg",
				valueType: VenusOS.Gauges_ValueType_RisingPercentage,
				borderColor: Theme.color.levelsPage.wasteWater.borderColor,
				//% "Waste water"
				name: qsTrId("gauges_waste_water")
			}
		case VenusOS.Tank_Type_LiveWell:
			return {
				icon: "/images/liveWell.svg",
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.liveWell.borderColor,
				//% "Live well"
				name: qsTrId("gauges_live_well")
			}
		case VenusOS.Tank_Type_Oil:
			return {
				icon: "/images/oil.svg",
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.oil.borderColor,
				//% "Oil"
				name: qsTrId("gauges_oil")
			}
		case VenusOS.Tank_Type_BlackWater:
			return {
				icon: "/images/blackWater.svg",
				valueType: VenusOS.Gauges_ValueType_RisingPercentage,
				borderColor: Theme.color.levelsPage.blackWater.borderColor,
				//% "Black water"
				name: qsTrId("gauges_black_water")
			}
		case VenusOS.Tank_Type_Gasoline:
			return {
				icon: "/images/tank.svg", // same as "Fuel"
				valueType: VenusOS.Gauges_ValueType_FallingPercentage,
				borderColor: Theme.color.levelsPage.gasoline.borderColor,
				//% "Gasoline"
				name: qsTrId("gauges_gasoline")
			}
		}
		console.warn("Unknown tank type", type)
		return {}
	}
}
