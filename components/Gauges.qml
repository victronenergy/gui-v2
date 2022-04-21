/*
** Copyright (C) 2021 Victron Energy B.V.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	enum ValueType {
		RisingPercentage,
		FallingPercentage
	}

	enum GaugeType {
		Battery = 999,
		// Following values are as per Tanks enum.
		// TODO put these into a common component.
		Fuel = 0,
		FreshWater = 1,
		WasteWater = 2,
		LiveWell = 3,
		Oil = 4,
		BlackWater = 5,
		Gasoline = 6
	}

	readonly property var gaugeTypes: [
		Gauges.Battery,
		Gauges.Fuel,
		Gauges.FreshWater,
		Gauges.WasteWater,
		Gauges.LiveWell,
		Gauges.Oil,
		Gauges.BlackWater,
		Gauges.Gasoline
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
		if (valueType === Gauges.RisingPercentage) {
			return statusFromRisingValue(value)
		}
		if (valueType === Gauges.FallingPercentage) {
			return statusFromFallingValue(value)
		}
		return Theme.Ok
	}

	function tankProperties(type) {
		switch (type) {
		case Gauges.GaugeType.Battery:
			return {
				icon: "/images/battery.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.ok,
				//% "Battery"
				name: qsTrId("gauges_battery")
			}
		case Gauges.GaugeType.Fuel:
			return {
				icon: "/images/fuel.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.fuel.borderColor,
				//% "Fuel"
				name: qsTrId("gauges_fuel")
			}
		case Gauges.GaugeType.FreshWater:
			return {
				icon: "/images/freshWater20x27.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.freshWater.borderColor,
				//% "Fresh water"
				name: qsTrId("gauges_fresh_water")
			}
		case Gauges.GaugeType.WasteWater:
			return {
				icon: "/images/wasteWater.svg",
				valueType: Gauges.RisingPercentage,
				borderColor: Theme.color.levelsPage.wasteWater.borderColor,
				//% "Waste water"
				name: qsTrId("gauges_waste_water")
			}
		case Gauges.GaugeType.LiveWell:
			return {
				icon: "/images/liveWell.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.liveWell.borderColor,
				//% "Live well"
				name: qsTrId("gauges_live_well")
			}
		case Gauges.GaugeType.Oil:
			return {
				icon: "/images/oil.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.oil.borderColor,
				//% "Oil"
				name: qsTrId("gauges_oil")
			}
		case Gauges.GaugeType.BlackWater:
			return {
				icon: "/images/blackWater.svg",
				valueType: Gauges.RisingPercentage,
				borderColor: Theme.color.levelsPage.blackWater.borderColor,
				//% "Black water"
				name: qsTrId("gauges_black_water")
			}
		case Gauges.GaugeType.Gasoline:
			return {
				icon: "/images/tank.svg", // same as "Fuel"
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.gasoline.borderColor,
				//% "Gasoline"
				name: qsTrId("gauges_gasoline")
			}
		}
		console.warn("Unknown tank type", type)
		return {}
	}
}
