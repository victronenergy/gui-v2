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

	/* Show setting depending on the mode */
	function showSetting() {
		for (var i = 0; i < arguments.length; i++) {
			if (arguments[i] === mode.currentValue)
				return true;
		}
		return false
	}

	ListRadioButtonGroup {
		id: mode
		//% "Relay function"
		text: qsTrId("batterysettingrelay_relay_function")
		dataSource: root.bindPrefix + "/Settings/Relay/Mode"
		optionModel: [
			//: Relay function is 'alarm'
			//% "Alarm"
			{ display: qsTrId("batterysettingrelay_alarm"), value: 0 },
			//% "Charger or generator start/stop"
			{ display: qsTrId("batterysettingrelay_charger_or_generator_start_stop"), value: 1 },
			//% "Manual control"
			{ display: qsTrId("batterysettingrelay_manual_control"), value: 2 },
			//% "Always open (don't use the relay)"
			{ display: qsTrId("batterysettingrelay_always_open_dont_use_the_relay"), value: 3 },
		]
		visible: defaultVisible && dataValid
	}

	ListSwitch {
		text: CommonWords.state
		dataSource: root.bindPrefix + "/Relay/0/State"
		enabled: mode.dataValid && mode.dataValue === 2
		visible: defaultVisible && dataValid
	}

	ListLabel {
		//% "Note that changing the Low state-of-charge setting also changes the Time-to-go discharge floor setting in the battery menu."
		text: qsTrId("batterysettingrelay_low_state_of_charge_setting_note")
		visible: dischargeFloorLinkedToRelay.valid && dischargeFloorLinkedToRelay.value !== 0 && lowSoc.visible

		DataPoint {
			id: dischargeFloorLinkedToRelay
			source: root.bindPrefix + "/Settings/DischargeFloorLinkedToRelay"
		}
	}

	ListRangeSlider {
		id: lowSoc

		text: CommonWords.low_state_of_charge
		sliderSuffix: "%"
		slider.firstColor: Theme.color.red
		slider.secondColor: Theme.color.green
		firstDataSource: root.bindPrefix + "/Settings/Relay/LowSoc"
		secondDataSource: root.bindPrefix + "/Settings/Relay/LowSocClear"
		visible: defaultVisible && dataValid && showSetting(0, 1)
	}

	ListRangeSlider {
		text: CommonWords.low_battery_voltage
		sliderSuffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color.red
		slider.secondColor: Theme.color.green
		firstDataSource: root.bindPrefix + "/Settings/Relay/LowVoltage"
		secondDataSource: root.bindPrefix + "/Settings/Relay/LowVoltageClear"
		visible: defaultVisible && dataValid && showSetting(0, 1)
	}

	ListRangeSlider {
		text: CommonWords.high_battery_voltage
		sliderSuffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color.green
		slider.secondColor: Theme.color.red
		firstDataSource: root.bindPrefix + "/Settings/Relay/HighVoltageClear"
		secondDataSource: root.bindPrefix + "/Settings/Relay/HighVoltage"
		visible: defaultVisible && dataValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.low_starter_battery_voltage
		sliderSuffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color.red
		slider.secondColor: Theme.color.green
		firstDataSource: root.bindPrefix + "/Settings/Relay/LowStarterVoltage"
		secondDataSource: root.bindPrefix + "/Settings/Relay/LowStarterVoltageClear"
		visible: defaultVisible && dataValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.high_starter_battery_voltage
		sliderSuffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color.green
		slider.secondColor: Theme.color.red
		firstDataSource: root.bindPrefix + "/Settings/Relay/HighStarterVoltageClear"
		secondDataSource: root.bindPrefix + "/Settings/Relay/HighStarterVoltage"
		visible: defaultVisible && dataValid && showSetting(0)
	}

	ListSwitch {
		//% "Fuse blown"
		text: qsTrId("batterysettingrelay_fuse_blown")
		dataSource: root.bindPrefix + "/Settings/Relay/FuseBlown"
		visible: defaultVisible && dataValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.low_battery_temperature
		slider.firstColor: Theme.color.red
		slider.secondColor: Theme.color.green
		firstDataSource: root.bindPrefix + "/Settings/Relay/LowBatteryTemperature"
		secondDataSource: root.bindPrefix + "/Settings/Relay/LowBatteryTemperatureClear"
		visible: defaultVisible && dataValid && showSetting(0)
		toSourceValue: function(v) {
			return Units.toKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
		fromSourceValue: function(v) {
			return Units.fromKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
	}

	ListRangeSlider {
		text: CommonWords.high_battery_temperature
		slider.firstColor: Theme.color.green
		slider.secondColor: Theme.color.red
		firstDataSource: root.bindPrefix + "/Settings/Relay/HighBatteryTemperatureClear"
		secondDataSource: root.bindPrefix + "/Settings/Relay/HighBatteryTemperature"
		visible: defaultVisible && dataValid && showSetting(0)
		toSourceValue: function(v) {
			return Units.toKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
		fromSourceValue: function(v) {
			return Units.fromKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
	}
}
