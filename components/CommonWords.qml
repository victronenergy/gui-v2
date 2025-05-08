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

	//% "Add device"
	readonly property string add_device: qsTrId("common_words_add_device")

	//: The role for an AC input (grid, genset, acload, etc.)
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

	//% "AC Sensor %1"
	property string ac_sensor_x: qsTrId("common_words_ac_sensor_x")

	//% "AC Sensors"
	property string ac_sensors: qsTrId("common_words_ac_sensor")

	//: Status is 'active'
	//% "Active"
	readonly property string active_status: qsTrId("common_words_active")

	//: Voltage alarm is at "Alarm" level
	//% "Alarm"
	readonly property string alarm: qsTrId("common_words_alarm")

	//% "Batteries"
	readonly property string batteries: qsTrId("common_words_batteries")

	//: Alarm configuration when 'overload' state is triggered
	//% "Overload"
	readonly property string alarm_setting_overload: qsTrId("common_words_alarm_setting_overload")

	//: Alarm configuration when 'DC ripple' state is triggered
	//% "DC ripple"
	readonly property string alarm_setting_dc_ripple: qsTrId("common_words_alarm_setting_dc_ripple")

	//% "Alarm setup"
	readonly property string alarm_setup: qsTrId("common_words_alarm_setup")

	//% "Alarm status"
	readonly property string alarm_status: qsTrId("common_words_alarm_status")

	//% "Alarms"
	readonly property string alarms: qsTrId("common_words_alarms")

	//% "Allow to charge"
	readonly property string allow_to_charge: qsTrId("common_words_allow_to_charge")

	//% "Allow to discharge"
	readonly property string allow_to_discharge: qsTrId("common_words_allow_to_discharge")

	//% "Auto"
	readonly property string auto: qsTrId("common_words_auto")

	//% "Automatic scanning"
	readonly property string automatic_scanning: qsTrId("common_words_automatic_scanning")

	//% "Auto-started \u2022 %1"
	readonly property string autostarted_dot_running_by: qsTrId("controlcard_generator_autostarted")

	//% "Battery"
	readonly property string battery: qsTrId("common_words_battery")

	//% "Battery current"
	readonly property string battery_current: qsTrId("common_words_battery_current")

	//% "Battery temperature"
	readonly property string battery_temperature: qsTrId("common_words_battery_temperature")

	//% "Battery voltage"
	readonly property string battery_voltage: qsTrId("common_words_battery_voltage")

	//% "Cancel"
	readonly property string cancel: qsTrId("common_words_cancel")

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

	//% "Daily history"
	readonly property string daily_history: qsTrId("common_words_daily_history")

	//% "DC"
	readonly property string dc: qsTrId("common_words_dc")

	//: Title for a menu item which displays debugging information
	//% "Debug"
	readonly property string debug: qsTrId("common_words_debug")

	//: Title for device information
	//% "Device"
	readonly property string device_info_title: qsTrId("common_words_device")

	//% "Devices"
	readonly property string devices: qsTrId("common_words_devices")

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

	//% "Error:"
	readonly property string error_colon: qsTrId("common_words_error_colon")

	//% "Error code"
	readonly property string error_code: qsTrId("common_words_error_code")

	//% "'%1' is not a number."
	readonly property string error_nan: qsTrId("common_words_error_not_a_number")

	//% "ESS"
	readonly property string ess: qsTrId("common_words_ess")

	//% "Firmware version"
	readonly property string firmware_version: qsTrId("common_words_firmware_version")

	//% "Generator"
	readonly property string generator: qsTrId("common_words_generator")

	//% "Grid"
	readonly property string grid: qsTrId("common_words_grid")

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

	//% "Input current limit"
	readonly property string input_current_limit: qsTrId("common_words_input_current_limit")

	//% "Inverter / Charger"
	readonly property string inverter_charger: qsTrId("common_words_inverter_charger")

	//: Inverter 'Eco' mode
	//% "Eco"
	readonly property string inverter_mode_eco: qsTrId("common_words_inverter_mode_eco")

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

	//% "Manual control"
	readonly property string manual_control: qsTrId("common_words_manual_control")

	//% "Manual start"
	readonly property string manual_start: qsTrId("common_words_manual_start")

	//% "Manual stop"
	readonly property string manual_stop: qsTrId("common_words_manual_stop")

	//% "Manufacturer"
	readonly property string manufacturer: qsTrId("common_words_manufacturer")

	//% "Maximum current"
	readonly property string maximum_current: qsTrId("common_words_maximum_current")

	//% "Maximum power"
	readonly property string maximum_power: qsTrId("common_words_maximum_power")

	//% "Maximum temperature"
	readonly property string maximum_temperature: qsTrId("common_words_maximum_temperature")

	//% "Maximum voltage"
	readonly property string maximum_voltage: qsTrId("common_words_maximum_voltage")

	//% "Minimum current"
	readonly property string minimum_current: qsTrId("common_words_minimum_current")

	//% "Minimum temperature"
	readonly property string minimum_temperature: qsTrId("common_words_minimum_temperature")

	//% "Minimum voltage"
	readonly property string minimum_voltage: qsTrId("common_words_minimum_voltage")

	//% "Mode"
	readonly property string mode: qsTrId("common_words_mode")

	//% "Model name"
	readonly property string model_name: qsTrId("common_words_model_name")

	//% "Network status"
	readonly property string network_status: qsTrId("common_words_network_status")

	//% "No"
	readonly property string no: qsTrId("common_words_no")

	//% "This setting is disabled when a Digital Multi Control is connected."
	readonly property string noAdjustableByDmc: qsTrId("common_words_setting_disabled_when_dmc_connected")

	//% "This setting is disabled when a VE.Bus BMS is connected."
	readonly property string noAdjustableByBms: qsTrId("common_words_setting_disabled_when_bms_connected")

	//% "No error"
	readonly property string no_error: qsTrId("common_words_no_error")

	//% "None"
	readonly property string none_option: qsTrId("common_words_none_option")

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

	//% "Open circuit"
	readonly property string open_circuit: qsTrId("common_words_open_circuit");

	//% "Overall history"
	readonly property string overall_history: qsTrId("common_words_overall_history")

	//% "Pending"
	readonly property string pending: qsTrId("common_words_pending")

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

	//% "Product page"
	readonly property string product_page: qsTrId("common_words_product_page");

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

	//% "Reset"
	readonly property string reset: qsTrId("common_words_reset")

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

	//: State of charge (as a percentage). %1 = the SOC value
	//% "SOC %1"
	readonly property string soc_with_prefix: qsTrId("common_words_soc")

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

	//: Change the mode value
	//% "Switch"
	readonly property string switch_mode: qsTrId("common_words_switch")

	//% "Temperature"
	readonly property string temperature: qsTrId("common_words_temperature")

	//% "Temperature sensor"
	readonly property string temperature_sensor: qsTrId("common_words_temperature_sensor")

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

	//% "VE.Bus Error"
	readonly property string vebus_error: qsTrId("common_words_vebus_error")

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
	//% "Yield Today"
	readonly property string yield_today: qsTrId("common_words_yield_today")

	//% "Dynamic power limit"
	readonly property string dynamic_power_limit: qsTrId("common_words_dynamic_power_limit")

	//% "This feature is disabled, since \"All modifications enabled\" under \"Settings -> General -> Modification checks\" is disabled."
	readonly property string all_modifications_disabled: qsTrId("common_words_large_features_currently_disabled")

	function acInputFromIndex(index) {
		return acInputFromNumber(index + 1)
	}

	function acInputFromNumber(number) {
		//: %1 = number of the AC input
		//% "AC input %1"
		return qsTrId("common_words_ac_input_number").arg(number)
	}

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

	function formatError(text, value) {
		//: %1 = error number, %2 = text description of this error
		//% "#%1 %2"
		return qsTrId("common_words_format_error").arg(value).arg(text)
	}

	function lastErrorName(errorIndex) {
		//: Details of last error
		//% "Last error"
		return errorIndex === 0 ? qsTrId("common_words_last_error")
			  //: Details of 2nd last error
			  //% "2nd last error"
			: errorIndex === 1 ? qsTrId("common_words_2nd_last_error")
			  //: Details of 3rd last error
			  //% "3rd last error"
			: errorIndex === 2 ? qsTrId("common_words_3rd_last_error")
			  //: Details of 4th last error
			  //% "4th last error"
			: errorIndex === 3 ? qsTrId("common_words_4th_last_error")
			: ""
	}
}
