/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	//% "State"
	readonly property string state: qsTrId("common_words_state");

	//% "Stopped"
	readonly property string stopped: qsTrId("common_words_stopped");

	//% "Error"
	readonly property string error: qsTrId("common_words_error");

	//% "No error"
	readonly property string no_error: qsTrId("common_words_no_error");

	//% "Enabled"
	readonly property string enabled: qsTrId("common_words_enabled");

	//% "Disabled"
	readonly property string disabled: qsTrId("common_words_disabled");

	//% "AC load"
	readonly property string ac_load: qsTrId("common_words_ac_load");

	//% "Battery voltage"
	readonly property string battery_voltage: qsTrId("common_words_battery_voltage");

	//% "Start value during quiet hours"
	readonly property string start_value_during_quiet_hours: qsTrId("common_words_start_value_during_quiet_hours");

	//% "Start after the condition is reached for"
	readonly property string start_after_the_condition_is_reached_for: qsTrId("common_words_start_after_condition_reached_for");

	//% "Stop value during quiet hours"
	readonly property string stop_value_during_quiet_hours: qsTrId("common_words_stop_value_during_quiet_hours");

	//% "Stop after the condition is reached for"
	readonly property string stop_after_the_condition_is_reached_for: qsTrId("common_words_stop_after_the_condition_is_reached_for")
}
