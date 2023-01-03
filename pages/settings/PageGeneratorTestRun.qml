/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	property string bindPrefix

	SettingsListView {

		model: ObjectModel {

			SettingsListSwitch {
				id: enableSwitch

				text: CommonWords.enable
				source: bindPrefix + "/TestRun/Enabled"
			}

			SettingsListSpinBox {
				//% "Run interval"
				text: qsTrId("run_interval")
				source: bindPrefix + "/TestRun/Interval"
				//% "%1 day(s)"
				button.text: qsTrId("page_generator_test_run_days").arg(value)
				stepSize: 1
				from: 1
				to: 30
			}

			SettingsListRadioButtonGroup {
				//% "Skip run if has been running for"
				text: qsTrId("page_generator_test_run_skip_run")
				source: bindPrefix + "/TestRun/SkipRuntime"
				optionModel: [
					//% "Start always"
					{ display: qsTrId("page_generator_test_run_start_always"), value: 0 },
					{ display: CommonWords.x_hours.arg(1), value: 3600 },
					{ display: CommonWords.x_hours.arg(2), value: 7200 },
					{ display: CommonWords.x_hours.arg(4), value: 14400 },
					{ display: CommonWords.x_hours.arg(6), value: 21600 },
					{ display: CommonWords.x_hours.arg(8), value: 28800 },
					{ display: CommonWords.x_hours.arg(10), value: 36000 },
				]
			}

			SettingsListTextField { // TODO: this will need changing when Serj provides a design for a calendar
				function onAccepted(text) {
					var newDate = Date.parse(text)/1000
					console.log("PageGeneratorTest: onAccepted", text, newDate)
					if ((newDate !== NaN) && (dataPoint.source)) {
						dataPoint.setValue(newDate)
					}
					textField.focus = false
					accepted()
				}

				//% "Run interval start date"
				text: qsTrId("page_generator_test_run_run_interval_start_date")
				secondaryText: Qt.formatDateTime(new Date(value * 1000), "yyyy-MM-dd")
				source: bindPrefix + "/TestRun/StartDate"
			}

			SettingsListTimeSelector {
				text: CommonWords.start_time
				source: bindPrefix + "/TestRun/StartTime"
			}

			SettingsListTimeSelector {
				//% "Run duration (hh:mm)"
				text: qsTrId("page_generator_test_run_run_duration")
				source: bindPrefix + "/TestRun/Duration"
				visible: !runTillBatteryFull.checked
			}

			SettingsListSwitch {
				id: runTillBatteryFull

				//% "Run until battery is fully charged"
				text: qsTrId("page_generator_test_run_run_until_fully_charged")
				source: bindPrefix + "/TestRun/RunTillBatteryFull"
				visible: valid
			}
		}
	}
}
