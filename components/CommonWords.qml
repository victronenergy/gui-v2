/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQml

QtObject {
	id: root

	//% "AC In"
	readonly property string ac_in: qsTrId("common_words_ac_in")

	//% "AC Input"
	readonly property string ac_input: qsTrId("common_words_ac_input")

	//% "AC Input 1"
	readonly property string ac_input_1: qsTrId("common_words_ac_input_1")

	//% "AC Input 2"
	readonly property string ac_input_2: qsTrId("common_words_ac_input_2")

	//: The role for an AC input (grid meter, genset, acload, etc.)
	//% "Role"
	readonly property string ac_input_role: qsTrId("common_words_ac_input_role")

	//% "AC load"
	readonly property string ac_load: qsTrId("common_words_ac_load")

	//% "AC Out"
	readonly property string ac_out: qsTrId("common_words_ac_out")

	//% "AC Output"
	readonly property string ac_output: qsTrId("common_words_ac_output")

	//: %1 = phase number (1-3)
	//% "AC Phase L%1"
	readonly property string ac_phase_x: qsTrId("common_words_ac_phase_x")

	//: Status is 'active'
	//% "Active"
	readonly property string active_status: qsTrId("common_words_active")

	//% "Alarms"
	readonly property string alarms: qsTrId("common_words_alarms")

	//% "Auto"
	readonly property string auto: qsTrId("common_words_auto")

	//% "Automatic scanning"
	readonly property string automatic_scanning: qsTrId("common_words_automatic_scanning")

	//% "Battery"
	readonly property string battery: qsTrId("common_words_battery")

	//% "Battery current"
	readonly property string battery_current: qsTrId("common_words_battery_current")

	//% "Battery voltage"
	readonly property string battery_voltage: qsTrId("common_words_battery_voltage")

	//% "Charge current"
	readonly property string charge_current: qsTrId("common_words_charge_current")

	//: "Charging" state
	//% "Charging"
	readonly property string charging: qsTrId("common_words_charging")

	//: Action to clear an error state
	//% "Clear error"
	readonly property string clear_error_action: qsTrId("common_words_clear_error_action")

	//: Status is 'closed'
	//% "Closed"
	readonly property string closed_status: qsTrId("common_words_closed_status")

	//% "Connected"
	readonly property string connected: qsTrId("common_words_connected");

	//: Electric current, as measured in Amps
	//% "Current"
	readonly property string current_amps: qsTrId("common_words_current_amps")

	//% "Current transformers"
	readonly property string current_transformers: qsTrId("common_words_current_transformers")

	//% "Custom name"
	readonly property string custom_name: qsTrId("common_words_custom_name")

	//: Title for device information
	//% "Device"
	readonly property string device_info_title: qsTrId("common_words_device")

	//% "Disabled"
	readonly property string disabled: qsTrId("common_words_disabled")

	//% "Discharging"
	readonly property string discharging: qsTrId("common_words_discharging")

	//% "Disconnected"
	readonly property string disconnected: qsTrId("common_words_disconnected")

	//% "Enable"
	readonly property string enable: qsTrId("common_words_enable")

	//% "Enabled"
	readonly property string enabled: qsTrId("common_words_enabled")

	//: Amount of charged energy
	//% "Energy"
	readonly property string energy: qsTrId("common_words_energy")

	//% "Error"
	readonly property string error: qsTrId("common_words_error")

	//% "Error code"
	readonly property string error_code: qsTrId("common_words_error_code")

	//% "Firmware version"
	readonly property string firmware_version: qsTrId("common_words_firmware_version")

	//% "Generator"
	readonly property string generator: qsTrId("common_words_generator")

	//% "Grid meter"
	readonly property string grid_meter: qsTrId("common_words_grid_meter")

	//% "High battery temperature"
	readonly property string high_battery_temperature: qsTrId("common_words_high_battery_temperature")

	//% "High battery voltage"
	readonly property string high_battery_voltage: qsTrId("common_words_high_battery_voltage")

	//: An alarm that triggers when the level is too high
	//% "High level alarm"
	readonly property string high_level_alarm: qsTrId("common_words_high_level_alarm")

	//% "High starter battery voltage"
	readonly property string high_starter_battery_voltage: qsTrId("common_words_high_starter_battery_voltage")

	//% "High temperature"
	readonly property string high_temperature: qsTrId("common_words_high_temperature")

	//% "High voltage alarms"
	readonly property string high_voltage_alarms: qsTrId("common_words_high_voltage_alarms")

	//% "History"
	readonly property string history: qsTrId("common_words_history")

	//% "%1 Hour(s)"
	readonly property string x_hours: qsTrId("common_words_x_hours")

	//% "Idle"
	readonly property string idle: qsTrId("common_words_idle")

	//: Status is 'inactive'
	//% "Inactive"
	readonly property string inactive_status: qsTrId("common_words_inactive_status")

	//% "Inverter / Charger"
	readonly property string inverter_charger: qsTrId("common_words_inverter_charger")

	//% "Inverter overload"
	readonly property string inverter_overload: qsTrId("common_words_inverter_overload")

	//% "IP address"
	readonly property string ip_address: qsTrId("common_words_ip_address")

	//% "Low battery temperature"
	readonly property string low_battery_temperature: qsTrId("common_words_low_battery_temperature")

	//% "Low battery voltage"
	readonly property string low_battery_voltage: qsTrId("common_words_low_battery_voltage")

	//: An alarm that triggers when the level is too low
	//% "Low level alarm"
	readonly property string low_level_alarm: qsTrId("common_words_low_level_alarm")

	//% "Low starter battery voltage"
	readonly property string low_starter_battery_voltage: qsTrId("common_words_low_starter_battery_voltage")

	//% "Low state-of-charge"
	readonly property string low_state_of_charge: qsTrId("common_words_low_state_of_charge")

	//% "Low temperature"
	readonly property string low_temperature: qsTrId("common_words_low_temperature")

	//% "Low voltage alarms"
	readonly property string low_voltage_alarms: qsTrId("common_words_low_voltage_alarms")

	//% "Manual"
	readonly property string manual: qsTrId("common_words_manual")

	//% "Manufacturer"
	readonly property string manufacturer: qsTrId("common_words_manufacturer")

	//% "Maximum temperature"
	readonly property string maximum_temperature: qsTrId("common_words_maximum_temperature")

	//% "Maximum voltage"
	readonly property string maximum_voltage: qsTrId("common_words_maximum_voltage")

	//% "Minimum temperature"
	readonly property string minimum_temperature: qsTrId("common_words_minimum_temperature")

	//% "Minimum voltage"
	readonly property string minimum_voltage: qsTrId("common_words_minimum_voltage")

	//% "Mode"
	readonly property string mode: qsTrId("common_words_mode")

	//% "Model name"
	readonly property string model_name: qsTrId("common_words_model_name")

	//% "No"
	readonly property string no: qsTrId("common_words_no")

	//% "No error"
	readonly property string no_error: qsTrId("common_words_no_error")

	//: Indicates there are no errors
	//% "None"
	readonly property string none_errors: qsTrId("common_words_none_errors")

	//% "Not available"
	readonly property string not_available: qsTrId("common_words_not_available")

	//% "Not connected"
	readonly property string not_connected: qsTrId("common_words_not_connected")

	//% "Off"
	readonly property string off: qsTrId("common_words_off");

	//% "Offline"
	readonly property string offline: qsTrId("common_words_offline");

	//% "OK"
	readonly property string ok: qsTrId("common_words_ok");

	//% "On"
	readonly property string on: qsTrId("common_words_on");

	//% "Online"
	readonly property string online: qsTrId("common_words_online");

	//: Status is 'open'
	//% "Open"
	readonly property string open_status: qsTrId("common_words_open_status");

	//% "Password"
	readonly property string password: qsTrId("common_words_password")

	//: Electric power, as measured in Watts
	//% "Power"
	readonly property string power_watts: qsTrId("common_words_power_watts")

	//% "Phase"
	readonly property string phase: qsTrId("common_words_phase")

	//: AC input or output position
	//% "Position"
	readonly property string position_ac: qsTrId("common_words_position_ac")

	//% "Press to clear"
	readonly property string press_to_clear: qsTrId("common_words_press_to_clear")

	//% "Press to reset"
	readonly property string press_to_reset: qsTrId("common_words_press_to_reset")

	//% "Press to scan"
	readonly property string press_to_scan: qsTrId("common_words_press_to_scan")

	//% "PV Inverter"
	readonly property string pv_inverter: qsTrId("common_words_pv_inverter")

	//: Photovoltaic power (for a solar charger or tracker)
	//% "PV Power"
	readonly property string pv_power: qsTrId("common_words_pv_power")

	//% "Quiet hours"
	readonly property string quiet_hours: qsTrId("common_words_quiet_hours")

	//: Relay switch
	//% "Relay"
	readonly property string relay: qsTrId("common_words_relay")

	//% "Reboot"
	readonly property string reboot: qsTrId("common_words_reboot")

	//% "Remove"
	readonly property string remove: qsTrId("common_words_remove")

	//: Status = "running"
	//% "Running"
	readonly property string running_status: qsTrId("common_words_running_status")

	//% "Scanning %1%"
	readonly property string scanning: qsTrId("common_words_scanning")

	//% "Serial number"
	readonly property string serial_number: qsTrId("common_words_serial_number")

	//% "Settings"
	readonly property string settings: qsTrId("common_words_settings")

	//% "Setup"
	readonly property string setup: qsTrId("common_words_setup")

	//% "Signal strength"
	readonly property string signal_strength: qsTrId("common_words_signal_strength");

	//: A speed measurement value
	//% "Speed"
	readonly property string speed: qsTrId("common_words_speed")

	//% "Standby"
	readonly property string standby: qsTrId("common_words_standby")

	//% "Start after the condition is reached for"
	readonly property string start_after_the_condition_is_reached_for: qsTrId("common_words_start_after_condition_reached_for")

	//% "Start time"
	readonly property string start_time: qsTrId("common_words_start_time")

	//% "Start value during quiet hours"
	readonly property string start_value_during_quiet_hours: qsTrId("common_words_start_value_during_quiet_hours")

	//% "Start when warning is active for"
	readonly property string start_when_warning_is_active_for: qsTrId("common_words_start_when_warning_is_active_for")

	//% "State"
	readonly property string state: qsTrId("common_words_state")

	//% "State of charge"
	readonly property string state_of_charge: qsTrId("common_words_state_of_charge")

	//% "Status"
	readonly property string status: qsTrId("common_words_status")

	//: Status = "start up". %1 = the startup status number
	//% "Startup (%1)"
	readonly property string startup_status: qsTrId("common_words_startup_status")

	//% "Stop value during quiet hours"
	readonly property string stop_value_during_quiet_hours: qsTrId("common_words_stop_value_during_quiet_hours")

	//% "Stop after the condition is reached for"
	readonly property string stop_after_the_condition_is_reached_for: qsTrId("common_words_stop_after_the_condition_is_reached_for")

	//% "Stopped"
	readonly property string stopped: qsTrId("common_words_stopped")

	//% "Temperature"
	readonly property string temperature: qsTrId("common_words_temperature")

	//% "Today"
	readonly property string today: qsTrId("common_words_today")

	//% "Total"
	readonly property string total: qsTrId("common_words_total")

	//: Solar tracker
	//% "Tracker"
	readonly property string tracker: qsTrId("common_words_tracker")

	//% "Type"
	readonly property string type: qsTrId("common_words_type")

	//% "Unique Identity Number"
	readonly property string unique_identity_number: qsTrId("common_words_unique_id_number")

	//: Status = "unknown"
	//% "Unknown"
	readonly property string unknown_status: qsTrId("common_words_unknown_status")

	//% "Voltage"
	readonly property string voltage: qsTrId("common_words_voltage")

	//% "VRM instance"
	readonly property string vrm_instance: qsTrId("common_words_vrm_instance")

	//% "When warning is cleared stop after"
	readonly property string when_warning_is_cleared_stop_after: qsTrId("common_words_when_warning_is_cleared_stop_after")

	//% "Yes"
	readonly property string yes: qsTrId("common_words_yes")

	//% "Yesterday"
	readonly property string yesterday: qsTrId("common_words_yesterday")

	//: Solar charger yield, in kWh (kilowatt hours)
	//% "Yield"
	readonly property string yield_kwh: qsTrId("common_words_yield_kwh")

	//: Solar charger yield for today, in kWh (kilowatt hours)
	//% "Yield today"
	readonly property string yield_today: qsTrId("common_words_yield_today")

	//% "Zero feed-in power limit"
	readonly property string zero_feed_in_power_limit: qsTrId("common_words_zero_feed_in_power_limit")

	function onOrOff(value) {
		if (value === 0 || value === false) {
			return off
		} else if (value === 1 || value === true) {
			return on
		} else {
			return unknown_status
		}
	}

	function yesOrNo(value) {
		return value === 1 || value === true ? yes : no
	}

	function enabledOrDisabled(value) {
		return value === 1 || value === true ? enabled : disabled
	}

	function activeOrInactive(value) {
		return value === 1 || value === true ? active_status : inactive_status
	}
}
