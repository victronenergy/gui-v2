/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

VisibleItemModel {
	id: root

	property string bindPrefix

	ListRangeSlider {
		text: CommonWords.low_state_of_charge
		slider.suffix: "%"
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSoc"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSocClear"
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.low_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowVoltage"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowVoltageClear"
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.high_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighVoltageClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighVoltage"
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.low_starter_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltage"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltageClear"
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.high_starter_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltageClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltage"
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.low_battery_temperature
		slider.suffix: Global.systemSettings.temperatureUnitSuffix
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperature"
		firstDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
		firstDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperatureClear"
		secondDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
		secondDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.high_battery_temperature
		slider.suffix: Global.systemSettings.temperatureUnitSuffix
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperatureClear"
		firstDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
		firstDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperature"
		secondDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
		secondDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		preferredVisible: firstDataItem.isValid && secondDataItem.isValid
	}
}
