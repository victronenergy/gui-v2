/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

DelegateComponentModel {
	id: root

	property string bindPrefix

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowSoc" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowSocClear" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.low_state_of_charge
			suffix: "%"
			firstColor: Theme.color_red
			secondColor: Theme.color_green
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSoc"
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSocClear"
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowVoltage" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowVoltageClear" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.low_battery_voltage
			suffix: "V"
			decimals: 1
			stepSize: 0.1
			firstColor: Theme.color_red
			secondColor: Theme.color_green
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowVoltage"
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowVoltageClear"
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighVoltageClear" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighVoltage" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.high_battery_voltage
			suffix: "V"
			decimals: 1
			stepSize: 0.1
			firstColor: Theme.color_green
			secondColor: Theme.color_red
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighVoltageClear"
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighVoltage"
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltage" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltageClear" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.low_starter_battery_voltage
			suffix: "V"
			decimals: 1
			stepSize: 0.1
			firstColor: Theme.color_red
			secondColor: Theme.color_green
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltage"
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowStarterVoltageClear"
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltageClear" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltage" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.high_starter_battery_voltage
			suffix: "V"
			decimals: 1
			stepSize: 0.1
			firstColor: Theme.color_green
			secondColor: Theme.color_red
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltageClear"
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighStarterVoltage"
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperature" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperatureClear" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.low_battery_temperature
			suffix: Global.systemSettings.temperatureUnitSuffix
			firstColor: Theme.color_red
			secondColor: Theme.color_green
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperature"
			firstDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
			firstDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperatureClear"
			secondDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
			secondDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		}
	}

	DelegateComponent {
		property VeQuickItem firstItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperatureClear" }
		property VeQuickItem secondItem: VeQuickItem { uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperature" }
		preferredVisible: firstItem.valid && secondItem.valid
		ListRangeSlider {
			text: CommonWords.high_battery_temperature
			suffix: Global.systemSettings.temperatureUnitSuffix
			firstColor: Theme.color_green
			secondColor: Theme.color_red
			firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperatureClear"
			firstDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
			firstDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
			secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperature"
			secondDataItem.sourceUnit: Units.unitToVeUnit(VenusOS.Units_Temperature_Kelvin)
			secondDataItem.displayUnit: Units.unitToVeUnit(Global.systemSettings.temperatureUnit)
		}
	}
}
