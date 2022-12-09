/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Page {
	id: root

	property string bindPrefix

	function minValueWarning()
	{
		//% "Value must be greater than stop value"
		Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("value_must_be_greater_than_stop_value"),
												   Theme.animation.generator.settings.valueOutOfRange.toastNotification.autoClose.duration)
	}

	function maxValueWarning()
	{
		//% "Value must be lower than start value"
		Global.dialogManager.showToastNotification(VenusOS.Notification_Info, qsTrId("value_must_be_lower_than_start_value"),
												   Theme.animation.generator.settings.valueOutOfRange.toastNotification.autoClose.duration)
	}

	//% "AC output"
	title: qsTrId("ac_output")

	SettingsListView {

		model: ObjectModel {

			SettingsListSwitch {
				id: enableSwitch

				//% "Use AC Load to start/stop"
				text: qsTrId("page_generator_ac_load_use_ac_load")
				source: bindPrefix + "/Enabled"
			}

			SettingsListRadioButtonGroup {
				//% "Measurement"
				text: qsTrId("page_generator_ac_load_measurement")
				source: bindPrefix + "/Measurement"
				model: [
					//% "Total consumption"
					{ display: qsTrId("total_consumption"), value: 0 },
					//% "Inverter total AC out"
					{ display: qsTrId("total_ac_out"), value: 1 },
					//% "Inverter AC out highest phase"
					{ display: qsTrId("ac_out_highest_phase"), value: 2 },
				]
			}

			SettingsListSpinBox {
				id: startValue
				//% "Start when power is higher than"
				text: qsTrId("start_when_power_is_higher_than")
				onMinValueReached: minValueWarning()
				visible: valid
				source: bindPrefix + "/StartValue"
				suffix: "W"
				stepSize: 5
				from: stopValue.value + stepSize
				to: 1602
			}

			SettingsListSpinBox {
				id: quietHoursStartValue
				text: CommonWords.start_value_during_quiet_hours
				onMinValueReached: minValueWarning()
				visible: valid
				source: bindPrefix + "/QuietHoursStartValue"
				suffix: "W"
				stepSize: 5
				from: quietHoursStopValue.value + stepSize
			}

			SettingsListSpinBox {
				id: startTime
				text: CommonWords.start_after_the_condition_is_reached_for
				visible: valid
				source: bindPrefix + "/StartTimer"
				suffix: "s"
				stepSize: 1
			}

			SettingsListSpinBox {
				id: stopValue
				//% "Stop when power is lower than"
				text: qsTrId("stop_when_power_is_lower_than")
				onMaxValueReached: maxValueWarning()
				visible: valid
				source: bindPrefix + "/StopValue"
				suffix: "W"
				stepSize: 5
				from: 0
				to: startValue.valid ? startValue.value - stepSize : 1000000
			}

			SettingsListSpinBox {
				id: quietHoursStopValue
				text: CommonWords.stop_value_during_quiet_hours
				onMaxValueReached: maxValueWarning()
				visible: valid
				source: bindPrefix + "/QuietHoursStopValue"
				suffix: "W"
				stepSize: 5
				to: quietHoursStartValue.valid ? quietHoursStartValue.value - stepSize : 1000000
				from: 0
			}

			SettingsListSpinBox {
				id: stopTime
				text: CommonWords.stop_after_the_condition_is_reached_for
				visible: valid
				source: bindPrefix + "/StopTimer"
				suffix: "s"
				stepSize: 1
			}
		}
	}
}

