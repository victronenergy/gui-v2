/*
** Copyright (C) 2021 Victron Energy B.V.
*/

.pragma library
.import Victron.VenusOS as V

const briefCentralGauges = [V.VenusOS.Tank_Type_Battery].concat(V.Global.tanks.tankTypes)

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
	}
	console.warn("Unknown tank type", type)
	return {}
}

