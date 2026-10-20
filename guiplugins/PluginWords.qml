/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

/*
	Common words, already translated into the user's language, for plugin text. For example:
	text: PluginWords.status

	The words come from gui-v2's CommonWords, with the same names, so plugins do not ship
	translations for them, and the words change when the user changes the language. If a word is
	renamed in CommonWords, it keeps its old name here.
*/
QtObject {
	// Answers and actions
	readonly property string yes: CommonWords.yes
	readonly property string no: CommonWords.no
	readonly property string reset: CommonWords.reset
	readonly property string remove: CommonWords.remove

	// Setting values
	readonly property string on: CommonWords.on
	readonly property string off: CommonWords.off
	readonly property string auto: CommonWords.auto
	readonly property string enabled: CommonWords.enabled
	readonly property string disabled: CommonWords.disabled

	// States
	readonly property string error: CommonWords.error
	readonly property string unknown_status: CommonWords.unknown_status

	// Labels
	readonly property string status: CommonWords.status
	readonly property string state: CommonWords.state
	readonly property string mode: CommonWords.mode
	readonly property string type: CommonWords.type
	readonly property string settings: CommonWords.settings
	readonly property string setup: CommonWords.setup
	readonly property string alarms: CommonWords.alarms
	readonly property string history: CommonWords.history
	readonly property string total: CommonWords.total

	// Quantities
	readonly property string temperature: CommonWords.temperature
	readonly property string voltage: CommonWords.voltage
	readonly property string current_amps: CommonWords.current_amps
	readonly property string power_watts: CommonWords.power_watts

	// Devices
	readonly property string battery: CommonWords.battery
	readonly property string manufacturer: CommonWords.manufacturer
	readonly property string model_name: CommonWords.model_name
	readonly property string serial_number: CommonWords.serial_number
	readonly property string firmware_version: CommonWords.firmware_version
	readonly property string custom_name: CommonWords.custom_name
}
