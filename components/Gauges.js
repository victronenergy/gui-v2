/*
** Copyright (C) 2021 Victron Energy B.V.
*/

.pragma library
.import Victron.VenusOS as V

function statusFromRisingValue(value) {
	if (value >= 85) return V.Theme.Critical
	if (value >= 60) return V.Theme.Warning
	return V.Theme.Ok
}

function statusFromFallingValue(value) {
	if (value <= 15) return V.Theme.Critical
	if (value <= 40) return V.Theme.Warning
	return V.Theme.Ok
}

function getValueStatus(value, valueType) {
	if (valueType === V.Enums.Gauges_ValueType_RisingPercentage) {
		return statusFromRisingValue(value)
	}
	if (valueType === V.Enums.Gauges_ValueType_FallingPercentage) {
		return statusFromFallingValue(value)
	}
	return V.Theme.Ok
}

function tankProperties(type) {
	switch (type) {
	case V.Enums.Tank_Type_Fuel:
		return {
			icon: "/images/fuel.svg",
			valueType: V.Enums.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.levelsPage.fuel.borderColor,
			//% "Fuel"
			name: qsTrId("tank_fuel")
		}
	case V.Enums.Tank_Type_FreshWater:
		return {
			icon: "/images/freshWater20x27.svg",
			valueType: V.Enums.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.levelsPage.freshWater.borderColor,
			//% "Fresh water"
			name: qsTrId("tank_fresh_water")
		}
	case V.Enums.Tank_Type_WasteWater:
		return {
			icon: "/images/wasteWater.svg",
			valueType: V.Enums.Gauges_ValueType_RisingPercentage,
			borderColor: V.Theme.color.levelsPage.wasteWater.borderColor,
			//% "Waste water"
			name: qsTrId("tank_waste_water")
		}
	case V.Enums.Tank_Type_LiveWell:
		return {
			icon: "/images/liveWell.svg",
			valueType: V.Enums.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.levelsPage.liveWell.borderColor,
			//% "Live well"
			name: qsTrId("tank_live_well")
		}
	case V.Enums.Tank_Type_Oil:
		return {
			icon: "/images/oil.svg",
			valueType: V.Enums.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.levelsPage.oil.borderColor,
			//% "Oil"
			name: qsTrId("tank_oil")
		}
	case V.Enums.Tank_Type_BlackWater:
		return {
			icon: "/images/blackWater.svg",
			valueType: V.Enums.Gauges_ValueType_RisingPercentage,
			borderColor: V.Theme.color.levelsPage.blackWater.borderColor,
			//% "Black water"
			name: qsTrId("tank_black_water")
		}
	case V.Enums.Tank_Type_Gasoline:
		return {
			icon: "/images/tank.svg", // same as "Fuel"
			valueType: V.Enums.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.levelsPage.gasoline.borderColor,
			//% "Gasoline"
			name: qsTrId("tank_gasoline")
		}
	}
	console.warn("Unknown tank type", type)
	return {}
}

