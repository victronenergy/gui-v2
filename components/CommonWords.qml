/*
** Copyright (C) 2022 Victron Energy B.V.
*/
pragma Singleton

import QtQml

QtObject {
	id: root

	//% "AC Input 1"
	readonly property string ac_input_1: qsTrId("common_words_ac_input_1")

	//% "AC Input 2"
	readonly property string ac_input_2: qsTrId("common_words_ac_input_2")

	//% "AC load"
	readonly property string ac_load: qsTrId("common_words_ac_load")

	//% "AC Output"
	readonly property string ac_output: qsTrId("common_words_ac_output")

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

	//% "Connected"
	readonly property string connected: qsTrId("common_words_connected");

	//: Electric current, as measured in Amps
	//% "Current"
	readonly property string current_amps: qsTrId("common_words_current_amps")

	//: Title for device information
	//% "Device"
	readonly property string device_info_title: qsTrId("common_words_device")

	//% "Disabled"
	readonly property string disabled: qsTrId("common_words_disabled")

	//% "Enable"
	readonly property string enable: qsTrId("common_words_enable")

	//% "Enabled"
	readonly property string enabled: qsTrId("common_words_enabled")

	//: Amount of charged energy for an EV charger
	//% "Energy"
	readonly property string energy_evcs: qsTrId("common_words_energy_evcs")

	//% "Error"
	readonly property string error: qsTrId("common_words_error")

	//% "%1 Hour(s)"
	readonly property string x_hours: qsTrId("common_words_x_hours")

	//% "Inverter overload"
	readonly property string inverter_overload: qsTrId("common_words_inverter_overload")

	//% "IP address"
	readonly property string ip_address: qsTrId("common_words_ip_address")

	//% "Manual"
	readonly property string manual: qsTrId("common_words_manual")

	//% "Mode"
	readonly property string mode: qsTrId("common_words_mode")

	//% "No"
	readonly property string no: qsTrId("common_words_no")

	//% "No error"
	readonly property string no_error: qsTrId("common_words_no_error")

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

	//% "Password"
	readonly property string password: qsTrId("common_words_password")

	//: Electric power, as measured in Watts
	//% "Power"
	readonly property string power_watts: qsTrId("common_words_power_watts")

	//% "Phase"
	readonly property string phase: qsTrId("common_words_phase")

	//% "Position"
	readonly property string position: qsTrId("common_words_position")

	//% "Press to reset"
	readonly property string press_to_reset: qsTrId("common_words_press_to_reset")

	//% "Press to scan"
	readonly property string press_to_scan: qsTrId("common_words_press_to_scan")

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

	//% "Scanning %1%"
	readonly property string scanning: qsTrId("common_words_scanning")

	//% "Signal strength"
	readonly property string signal_strength: qsTrId("common_words_signal_strength");

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

	//% "Status"
	readonly property string status: qsTrId("common_words_status")

	//% "Today"
	readonly property string today: qsTrId("common_words_today")

	//% "Total"
	readonly property string total: qsTrId("common_words_total")

	//: Solar tracker
	//% "Tracker"
	readonly property string tracker: qsTrId("common_words_tracker")

	//% "Stop value during quiet hours"
	readonly property string stop_value_during_quiet_hours: qsTrId("common_words_stop_value_during_quiet_hours")

	//% "Stop after the condition is reached for"
	readonly property string stop_after_the_condition_is_reached_for: qsTrId("common_words_stop_after_the_condition_is_reached_for")

	//% "Stopped"
	readonly property string stopped: qsTrId("common_words_stopped")

	//% "Voltage"
	readonly property string voltage: qsTrId("common_words_voltage")

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

	function onOrOff(value) {
		if (value === 0) {
			return off
		} else if (value === 1) {
			return on
		} else {
			//% "Unknown"
			return qsTrId("utils_unknown")
		}
	}

	function yesOrNo(value) {
		return value === 1 ? yes : no
	}
}
