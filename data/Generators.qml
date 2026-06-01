/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property string generator1ServiceUid: BackendConnection.type === BackendConnection.MqttSource
										  ? ""
										  : BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop1"

	readonly property FilteredDeviceModel model: FilteredDeviceModel {
		serviceTypes: ["generator"]
		sorting: FilteredDeviceModel.DeviceInstance
	}

	readonly property FilteredDeviceModel dcModel: FilteredDeviceModel {
		serviceTypes: ["dcgenset"]
		sorting: FilteredDeviceModel.DeviceInstance
	}

	readonly property bool multipleDcGensetsSupported: _multipleDcGensetsSupported.valid

	readonly property VeQuickItem _multipleDcGensetsSupported: VeQuickItem { // the backend sets this to true whenever there are 2 or more dc gensets
		uid: root.generator1ServiceUid ? root.generator1ServiceUid + "/MultipleGensets/GensetsEnabled" : ""
	}

	property Instantiator _generator1ServiceUidFinder: Instantiator {
		model: BackendConnection.type === BackendConnection.MqttSource ? root.model : null
		delegate: VeQuickItem {
			uid: model.device?.serviceUid ? model.device.serviceUid + "/GensetServiceType" : ""
			onValueChanged: {
				if (value === "dcgenset") {
					// This must be the startstop1 service, i.e. likely mqtt/generator/1.
					root.generator1ServiceUid = model.device.serviceUid
				}
			}
		}
	}

	function stateAndCondition(state, conditionCode) {
		switch (state) {
		case VenusOS.Generators_State_WarmUp:
		case VenusOS.Generators_State_CoolDown:
		case VenusOS.Generators_State_Stopping:
		case VenusOS.Generators_State_Error:
		case VenusOS.Generators_State_StoppedByTankLevel:
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
		case VenusOS.Generators_State_StoppedByTankLevel:
			//% "Stopped by tank level"
			return qsTrId("page_generator_stopped_by_tank_level")
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
			console.warn("Invalid RunningByConditionCode:", runningBy)
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
