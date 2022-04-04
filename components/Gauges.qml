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
		case Tanks.TankType.Fuel:
			return {
				icon: "/images/fuel.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.fuel.borderColor,
				//% "Fuel"
				name: qsTrId("tank_fuel")
			}
		case Tanks.TankType.FreshWater:
			return {
				icon: "/images/freshWater20x27.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.freshWater.borderColor,
				//% "Fresh water"
				name: qsTrId("tank_fresh_water")
			}
		case Tanks.TankType.WasteWater:
			return {
				icon: "/images/wasteWater.svg",
				valueType: Gauges.RisingPercentage,
				borderColor: Theme.color.levelsPage.wasteWater.borderColor,
				//% "Waste water"
				name: qsTrId("tank_waste_water")
			}
		case Tanks.TankType.LiveWell:
			return {
				icon: "/images/liveWell.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.liveWell.borderColor,
				//% "Live well"
				name: qsTrId("tank_live_well")
			}
		case Tanks.TankType.Oil:
			return {
				icon: "/images/oil.svg",
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.oil.borderColor,
				//% "Oil"
				name: qsTrId("tank_oil")
			}
		case Tanks.TankType.BlackWater:
			return {
				icon: "/images/blackWater.svg",
				valueType: Gauges.RisingPercentage,
				borderColor: Theme.color.levelsPage.blackWater.borderColor,
				//% "Black water"
				name: qsTrId("tank_black_water")
			}
		case Tanks.TankType.Gasoline:
			return {
				icon: "/images/tank.svg", // same as "Fuel"
				valueType: Gauges.FallingPercentage,
				borderColor: Theme.color.levelsPage.gasoline.borderColor,
				//% "Gasoline"
				name: qsTrId("tank_gasoline")
			}
		}
		console.warn("Unknown tank type", type)
		return {}
	}
}
