/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
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
		dataItem.uid: root.bindPrefix + "/Settings/Relay/Mode"
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
		visible: defaultVisible && dataItem.isValid
	}

	ListSwitch {
		text: CommonWords.state
		dataItem.uid: root.bindPrefix + "/Relay/0/State"
		enabled: mode.dataItem.isValid && mode.dataItem.value === 2
		visible: defaultVisible && dataItem.isValid
	}

	ListLabel {
		//% "Note that changing the Low state-of-charge setting also changes the Time-to-go discharge floor setting in the battery menu."
		text: qsTrId("batterysettingrelay_low_state_of_charge_setting_note")
		visible: dischargeFloorLinkedToRelay.isValid && dischargeFloorLinkedToRelay.value !== 0 && lowSoc.visible

		VeQuickItem {
			id: dischargeFloorLinkedToRelay
			uid: root.bindPrefix + "/Settings/DischargeFloorLinkedToRelay"
		}
	}

	ListRangeSlider {
		id: lowSoc

		text: CommonWords.low_state_of_charge
		slider.suffix: "%"
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/LowSoc"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/LowSocClear"
		visible: defaultVisible && dataItem.isValid && showSetting(0, 1)
	}

	ListRangeSlider {
		text: CommonWords.low_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/LowVoltage"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/LowVoltageClear"
		visible: defaultVisible && dataItem.isValid && showSetting(0, 1)
	}

	ListRangeSlider {
		text: CommonWords.high_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/HighVoltageClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/HighVoltage"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.low_starter_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/LowStarterVoltage"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/LowStarterVoltageClear"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.high_starter_battery_voltage
		slider.suffix: "V"
		slider.decimals: 1
		slider.stepSize: 0.1
		slider.firstColor: Theme.color_green
		slider.secondColor: Theme.color_red
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/HighStarterVoltageClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/HighStarterVoltage"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
	}

	ListSwitch {
		//% "Fuse blown"
		text: qsTrId("batterysettingrelay_fuse_blown")
		dataItem.uid: root.bindPrefix + "/Settings/Relay/FuseBlown"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
	}

	ListRangeSlider {
		text: CommonWords.low_battery_temperature
		slider.firstColor: Theme.color_red
		slider.secondColor: Theme.color_green
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/LowBatteryTemperature"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/LowBatteryTemperatureClear"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
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
		firstDataItem.uid: root.bindPrefix + "/Settings/Relay/HighBatteryTemperatureClear"
		secondDataItem.uid: root.bindPrefix + "/Settings/Relay/HighBatteryTemperature"
		visible: defaultVisible && dataItem.isValid && showSetting(0)
		toSourceValue: function(v) {
			return Units.toKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
		fromSourceValue: function(v) {
			return Units.fromKelvin(v, Global.systemSettings.temperatureUnit.value)
		}
	}
}
