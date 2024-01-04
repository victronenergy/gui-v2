/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

ObjectModel {
	id: root

	property string bindPrefix

	ListRangeSlider {
		text: CommonWords.low_state_of_charge
		slider.suffix: "%"
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSoc"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowSocClear"
		visible: defaultVisible && dataItem.isValid
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
		visible: defaultVisible && dataItem.isValid
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
		visible: defaultVisible && dataItem.isValid
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
		visible: defaultVisible && dataItem.isValid
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
		visible: defaultVisible && dataItem.isValid
	}

	ListRangeSlider {
		text: CommonWords.low_battery_temperature
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperature"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/LowBatteryTemperatureClear"
		visible: defaultVisible && dataItem.isValid
		toSourceValue: function(v) {
			return Units.toKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
		fromSourceValue: function(v) {
			return Units.fromKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
	}

	ListRangeSlider {
		text: CommonWords.high_battery_temperature
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperatureClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Alarm/HighBatteryTemperature"
		visible: defaultVisible && dataItem.isValid
		toSourceValue: function(v) {
			return Units.toKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
		fromSourceValue: function(v) {
			return Units.fromKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
	}
}
