/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

.pragma library
.import Victron.VenusOS as V

const briefCentralGauges = [V.VenusOS.Tank_Type_Battery].concat(V.Global.tanks.tankTypes)

function statusFromRisingValue(value) {
	if (value >= 90) return V.Theme.Critical
	if (value >= 80) return V.Theme.Warning
	return V.Theme.Ok
}

function statusFromFallingValue(value) {
	if (value <= 10) return V.Theme.Critical
	if (value <= 20) return V.Theme.Warning
	return V.Theme.Ok
}

function getValueStatus(value, valueType) {
	if (valueType === V.VenusOS.Gauges_ValueType_RisingPercentage) {
		return statusFromRisingValue(value)
	}
	if (valueType === V.VenusOS.Gauges_ValueType_FallingPercentage) {
		return statusFromFallingValue(value)
	}
	return V.Theme.Ok
}

function tankProperties(type) {
	switch (type) {
	case V.VenusOS.Tank_Type_Battery:
		return {
			icon: "/images/battery.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.ok,
			//% "Battery"
			name: qsTrId("gauges_battery")
		}
	case V.VenusOS.Tank_Type_Fuel:
		return {
			icon: "/images/fuel.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.fuel,
			//% "Fuel"
			name: qsTrId("gauges_fuel")
		}
	case V.VenusOS.Tank_Type_FreshWater:
		return {
			icon: "/images/freshWater20x27.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.freshWater,
			//% "Fresh water"
			name: qsTrId("gauges_fresh_water")
		}
	case V.VenusOS.Tank_Type_WasteWater:
		return {
			icon: "/images/wasteWater.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			borderColor: V.Theme.color.wasteWater,
			//% "Waste water"
			name: qsTrId("gauges_waste_water")
		}
	case V.VenusOS.Tank_Type_LiveWell:
		return {
			icon: "/images/liveWell.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.liveWell,
			//% "Live well"
			name: qsTrId("gauges_live_well")
		}
	case V.VenusOS.Tank_Type_Oil:
		return {
			icon: "/images/oil.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.oil,
			//% "Oil"
			name: qsTrId("gauges_oil")
		}
	case V.VenusOS.Tank_Type_BlackWater:
		return {
			icon: "/images/blackWater.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			borderColor: V.Theme.color.blackWater,
			//% "Black water"
			name: qsTrId("gauges_black_water")
		}
	case V.VenusOS.Tank_Type_Gasoline:
		return {
			icon: "/images/tank.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.gasoline,
			//% "Gasoline"
			name: qsTrId("gauges_gasoline")
		}
	case V.VenusOS.Tank_Type_Diesel:
		return {
			icon: "/images/tank.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.diesel,
			//% "Diesel"
			name: qsTrId("gauges_diesel")
		}
	case V.VenusOS.Tank_Type_LPG:
		return {
			icon: "/images/icon_lpg_32.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.lpg,
			//% "LPG"
			name: qsTrId("gauges_lpg")
		}
	case V.VenusOS.Tank_Type_LNG:
		return {
			icon: "/images/icon_lng_32.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.lng,
			//% "LNG"
			name: qsTrId("gauges_lng")
		}
	case V.VenusOS.Tank_Type_HydraulicOil:
		return {
			icon: "/images/icon_hydraulic_oil_32.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.hydraulicOil,
			//% "Hydraulic oil"
			name: qsTrId("gauges_hydraulic_oil")
		}
	case V.VenusOS.Tank_Type_RawWater:
		return {
			icon: "/images/icon_raw_water_32.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			borderColor: V.Theme.color.rawWater,
			//% "Raw water"
			name: qsTrId("gauges_raw_water")
		}
	}
	console.warn("Unknown tank type", type)
	return {}
}

