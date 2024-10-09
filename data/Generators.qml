/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property DeviceModel model: DeviceModel {
		modelId: "generators"
		sortBy: BaseDeviceModel.SortByDeviceInstance
	}

	function addGenerator(generator) {
		model.addDevice(generator)
	}

	function removeGenerator(generator) {
		model.removeDevice(generator.serviceUid)
	}

	function reset() {
		model.clear()
	}

	function isAutoStarted(conditionCode) {
		switch (conditionCode) {
		case VenusOS.Generators_RunningBy_LossOfCommunication:
		case VenusOS.Generators_RunningBy_Soc:
		case VenusOS.Generators_RunningBy_AcLoad:
		case VenusOS.Generators_RunningBy_BatteryCurrent:
		case VenusOS.Generators_RunningBy_BatteryVoltage:
		case VenusOS.Generators_RunningBy_InverterHighTemperature:
		case VenusOS.Generators_RunningBy_InverterOverload:
			return true
		default:
			return false
		}
	}

	function stateToText(state, conditionCode) {
		switch (state) {
		case VenusOS.Generators_State_WarmUp:
			//% "Warm-up"
			return qsTrId("page_generator_warm_up")
		case VenusOS.Generators_State_CoolDown:
			//% "Cool-down"
			return qsTrId("page_generator_cool_down")
		case VenusOS.Generators_State_Stopping:
			//% "Stopping"
			return qsTrId("page_generator_stopping")
		case VenusOS.Generators_State_Error:
			return CommonWords.error
		}

		switch (conditionCode) {
		case VenusOS.Generators_RunningBy_LossOfCommunication:
			//% "Running by loss of communication"
			return qsTrId("settings_running_by_loss_of_communication")
		case VenusOS.Generators_RunningBy_Soc:
			//% "Running by SOC condition"
			return qsTrId("settings_running_by_soc_condition")
		case VenusOS.Generators_RunningBy_AcLoad:
			//% "Running by AC Load condition"
			return qsTrId("settings_running_by_ac_load_condition")
		case VenusOS.Generators_RunningBy_BatteryCurrent:
			//% "Running by battery current condition"
			return qsTrId("settings_running_by_battery_current_condition")
		case VenusOS.Generators_RunningBy_BatteryVoltage:
			//% "Running by battery voltage condition"
			return qsTrId("settings_running_by_battery_voltage_condition")
		case VenusOS.Generators_RunningBy_InverterHighTemperature:
			//% "Running by inverter high temperature"
			return qsTrId("settings_running_by_inverter_high_temperature")
		case VenusOS.Generators_RunningBy_InverterOverload:
			//% "Running by inverter overload"
			return qsTrId("settings_running_by_inverter_overload")
		case VenusOS.Generators_RunningBy_TestRun:
			//% "Test run"
			return qsTrId("settings_running_by_test_run")
		case VenusOS.Generators_RunningBy_Manual:
			//% "Manually started"
			return qsTrId("settings_manually_started")
		default:
			return CommonWords.stopped
		}
	}

	function controlCardStatusText(state, conditionCode) {
		switch (state) {
		case VenusOS.Generators_State_WarmUp:
		case VenusOS.Generators_State_CoolDown:
		case VenusOS.Generators_State_Stopping:
		case VenusOS.Generators_State_Error:
			return stateToText(state, conditionCode)
		}

		switch (conditionCode) {
		case VenusOS.Generators_RunningBy_Soc:
		case VenusOS.Generators_RunningBy_AcLoad:
		case VenusOS.Generators_RunningBy_BatteryCurrent:
		case VenusOS.Generators_RunningBy_BatteryVoltage:
		case VenusOS.Generators_RunningBy_InverterHighTemperature:
		case VenusOS.Generators_RunningBy_InverterOverload:
		case VenusOS.Generators_RunningBy_LossOfCommunication:
			return CommonWords.running_status
		}

		return stateToText(state, conditionCode)
	}

	function autoStartReason(conditionCode) {
		switch (conditionCode) {
		case VenusOS.Generators_RunningBy_LossOfCommunication:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "loss of communication"
			return qsTrId("settings_loss_of_communication")
		case VenusOS.Generators_RunningBy_Soc:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "SOC condition"
			return qsTrId("settings_soc_condition")
		case VenusOS.Generators_RunningBy_AcLoad:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "AC load condition"
			return qsTrId("settings_ac_load_condition")
		case VenusOS.Generators_RunningBy_BatteryCurrent:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "battery current condition"
			return qsTrId("settings_battery_current_condition")
		case VenusOS.Generators_RunningBy_BatteryVoltage:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "battery voltage condition"
			return qsTrId("settings_battery_voltage_condition")
		case VenusOS.Generators_RunningBy_InverterHighTemperature:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "inverter high temperature"
			return qsTrId("settings_inverter_high_temperature") // Intentionally omit 'condition' suffix, too long for the generator card otherwise
		case VenusOS.Generators_RunningBy_InverterOverload:
			//: Translations should not be longer than the longest engineering text in this list.
			//% "inverter overload condition"
			return qsTrId("settings_inverter_overload_condition")
		default:
			return ""
		}
	}

	Component.onCompleted: Global.generators = root
}
