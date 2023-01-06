/*
** Copyright (C) 2022 Victron Energy B.V.
*/
pragma Singleton

import QtQml

QtObject {
	id: root

	//% "AC load"
	readonly property string ac_load: qsTrId("common_words_ac_load");

	//% "Battery current"
	readonly property string battery_current: qsTrId("common_words_battery_current")

	//% "Battery voltage"
	readonly property string battery_voltage: qsTrId("common_words_battery_voltage");

	//% "Disabled"
	readonly property string disabled: qsTrId("common_words_disabled");

	//% "Enable"
	readonly property string enable: qsTrId("common_words_enable");

	//% "Enabled"
	readonly property string enabled: qsTrId("common_words_enabled");

	//% "Error"
	readonly property string error: qsTrId("common_words_error");

	//% "%1 Hour(s)"
	readonly property string x_hours: qsTrId("common_words_x_hours")

	//% "Inverter overload"
	readonly property string inverter_overload: qsTrId("common_words_inverter_overload")

	//% "IP address"
	readonly property string ip_address: qsTrId("common_words_ip_address")

	//% "No error"
	readonly property string no_error: qsTrId("common_words_no_error");

	//% "Offline"
	readonly property string offline: qsTrId("common_words_offline");

	//% "Online"
	readonly property string online: qsTrId("common_words_online");

	//% "Password"
	readonly property string password: qsTrId("common_words_password")

	//% "Quiet hours"
	readonly property string quiet_hours: qsTrId("common_words_quiet_hours");

	//% "Signal strength"
	readonly property string signal_strength: qsTrId("common_words_signal_strength");

	//% "Start after the condition is reached for"
	readonly property string start_after_the_condition_is_reached_for: qsTrId("common_words_start_after_condition_reached_for");

	//% "Start time"
	readonly property string start_time: qsTrId("common_words_start_time")

	//% "Start value during quiet hours"
	readonly property string start_value_during_quiet_hours: qsTrId("common_words_start_value_during_quiet_hours");

	//% "Start when warning is active for"
	readonly property string start_when_warning_is_active_for: qsTrId("common_words_start_when_warning_is_active_for");

	//% "State"
	readonly property string state: qsTrId("common_words_state");

	//% "Stop value during quiet hours"
	readonly property string stop_value_during_quiet_hours: qsTrId("common_words_stop_value_during_quiet_hours");

	//% "Stop after the condition is reached for"
	readonly property string stop_after_the_condition_is_reached_for: qsTrId("common_words_stop_after_the_condition_is_reached_for")

	//% "Stopped"
	readonly property string stopped: qsTrId("common_words_stopped");

	//% "When warning is cleared stop after"
	readonly property string when_warning_is_cleared_stop_after: qsTrId("common_words_when_warning_is_cleared_stop_after");
}
