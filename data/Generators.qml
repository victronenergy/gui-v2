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

	function stateAndCondition(state, conditionCode) {
		switch (state) {
		case VenusOS.Generators_State_WarmUp:
		case VenusOS.Generators_State_CoolDown:
		case VenusOS.Generators_State_Stopping:
		case VenusOS.Generators_State_Error:
			return stateText(state)
		}

		return runningByText(conditionCode)
	}

	function stateText(state) {
		switch (state) {
		case VenusOS.Generators_State_Stopped:
			return CommonWords.stopped
		case VenusOS.Generators_State_Running:
			return CommonWords.running_status
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
		default:
			return "--"
		}
	}

	function runningByText(runningBy) {
		switch (runningBy) {
		case VenusOS.Generators_RunningBy_NotRunning:
			//% "Not running"
			return qsTrId("generator_not_running")
		case VenusOS.Generators_RunningBy_Manual:
			//% "Manually started"
			return qsTrId("generator_manually_started")
		case VenusOS.Generators_RunningBy_PeriodicRun:
			//% "Periodic run"
			return qsTrId("generator_periodic_run")
		case VenusOS.Generators_RunningBy_LossOfCommunication:
			//% "Loss of communication"
			return qsTrId("settings_loss_of_communication")
		case VenusOS.Generators_RunningBy_Soc:
			//% "SOC condition"
			return qsTrId("settings_soc_condition")
		case VenusOS.Generators_RunningBy_AcLoad:
			//% "AC load condition"
			return qsTrId("settings_ac_load_condition")
		case VenusOS.Generators_RunningBy_BatteryCurrent:
			//% "Battery current condition"
			return qsTrId("settings_battery_current_condition")
		case VenusOS.Generators_RunningBy_BatteryVoltage:
			//% "Battery voltage condition"
			return qsTrId("settings_battery_voltage_condition")
		case VenusOS.Generators_RunningBy_InverterHighTemperature:
			//% "Inverter high temperature"
			return qsTrId("settings_inverter_high_temperature") // Intentionally omit 'condition' suffix, too long for the generator card otherwise
		case VenusOS.Generators_RunningBy_InverterOverload:
			//% "Inverter overload condition"
			return qsTrId("settings_inverter_overload_condition")
		default:
			console.warn("Invalid RunningByConditionCode")
			return "--"
		}
	}

	function isAutoStarted(runningBy) {
		switch (runningBy) {
		case VenusOS.Generators_RunningBy_PeriodicRun:
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

	Component.onCompleted: Global.generators = root
}
