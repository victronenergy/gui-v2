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
			icon: "qrc:/images/icon_battery_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_ok,
			//% "Battery"
			name: qsTrId("gauges_battery")
		}
	case V.VenusOS.Tank_Type_Fuel:
		return {
			icon: "qrc:/images/icon_fuel_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_fuel,
			//% "Fuel"
			name: qsTrId("gauges_fuel")
		}
	case V.VenusOS.Tank_Type_FreshWater:
		return {
			icon: "qrc:/images/icon_fresh_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_freshWater,
			//% "Fresh water"
			name: qsTrId("gauges_fresh_water")
		}
	case V.VenusOS.Tank_Type_WasteWater:
		return {
			icon: "qrc:/images/icon_waste_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			color: V.Theme.color_wasteWater,
			//% "Waste water"
			name: qsTrId("gauges_waste_water")
		}
	case V.VenusOS.Tank_Type_LiveWell:
		return {
			icon: "qrc:/images/icon_livewell_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_liveWell,
			//% "Live well"
			name: qsTrId("gauges_live_well")
		}
	case V.VenusOS.Tank_Type_Oil:
		return {
			icon: "qrc:/images/icon_oil_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_oil,
			//% "Oil"
			name: qsTrId("gauges_oil")
		}
	case V.VenusOS.Tank_Type_BlackWater:
		return {
			icon: "qrc:/images/icon_black_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_RisingPercentage,
			color: V.Theme.color_blackWater,
			//% "Black water"
			name: qsTrId("gauges_black_water")
		}
	case V.VenusOS.Tank_Type_Gasoline:
		return {
			icon: "qrc:/images/icon_fuel_24.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_gasoline,
			//% "Gasoline"
			name: qsTrId("gauges_gasoline")
		}
	case V.VenusOS.Tank_Type_Diesel:
		return {
			icon: "qrc:/images/icon_fuel_24.svg", // same as "Fuel"
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_diesel,
			//% "Diesel"
			name: qsTrId("gauges_diesel")
		}
	case V.VenusOS.Tank_Type_LPG:
		return {
			icon: "qrc:/images/icon_lpg_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_lpg,
			//% "LPG"
			name: qsTrId("gauges_lpg")
		}
	case V.VenusOS.Tank_Type_LNG:
		return {
			icon: "qrc:/images/icon_lng_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_lng,
			//% "LNG"
			name: qsTrId("gauges_lng")
		}
	case V.VenusOS.Tank_Type_HydraulicOil:
		return {
			icon: "qrc:/images/icon_hydraulic_oil_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_hydraulicOil,
			//% "Hydraulic oil"
			name: qsTrId("gauges_hydraulic_oil")
		}
	case V.VenusOS.Tank_Type_RawWater:
		return {
			icon: "qrc:/images/icon_raw_water_24.svg",
			valueType: V.VenusOS.Gauges_ValueType_FallingPercentage,
			color: V.Theme.color_rawWater,
			//% "Raw water"
			name: qsTrId("gauges_raw_water")
		}
	}
	console.warn("Unknown tank type", type)
	return {}
}

function width(count, maxCount, availableSpace){
	const _count = Math.min(maxCount, count)
	if (_count <= 3) {
		return V.Theme.geometry_levelsPage_panel_max_width
	} else {
		const _spacing = spacing(_count)
		const margin = V.Theme.geometry_levelsPage_environment_horizontalMargin
		return Math.round((availableSpace - 2*margin + _spacing)/_count) - _spacing
	}
}

function height(expanded) {
	return expanded ? V.Theme.geometry_levelsPage_panel_expanded_height
					: V.Theme.geometry_levelsPage_panel_compact_height
}

function spacing(count) {
	if (count <= 1) {
		return 0
	} else if (count === 2) {
		return V.Theme.geometry_levelsPage_gauge_spacing_large
	} else if (count === 3) {
		return V.Theme.geometry_levelsPage_gauge_spacing_medium
	} else if (count === 4) {
		return V.Theme.geometry_levelsPage_gauge_spacing_small
	} else {
		return V.Theme.geometry_levelsPage_gauge_spacing_tiny
	}
}
