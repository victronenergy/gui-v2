/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	property string bindPrefix

	VeQuickItem {
		id: runTillBatteryFullItem
		uid: bindPrefix + "/TestRun/RunTillBatteryFull"
	}

	GradientListView {

		model: DelegateComponentModel {

			DelegateComponent {
				ListSwitch {
					id: enableSwitch

					text: CommonWords.enable
					dataItem.uid: bindPrefix + "/TestRun/Enabled"
				}
			}

			DelegateComponent {
				ListSpinBox {
					//% "Run interval"
					text: qsTrId("run_interval")
					dataItem.uid: bindPrefix + "/TestRun/Interval"
					//% "%1 day(s)"
					secondaryText: qsTrId("page_generator_test_run_days").arg(value)
					stepSize: 1
					from: 1
					to: 30
				}
			}

			DelegateComponent {
				ListRadioButtonGroup {
					//% "Skip run if has been running for"
					text: qsTrId("page_generator_test_run_skip_run")
					dataItem.uid: bindPrefix + "/TestRun/SkipRuntime"
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
			}

			DelegateComponent {
				ListDateSelector {
					//% "Run interval start date"
					text: qsTrId("page_generator_test_run_run_interval_start_date")
					dataItem.uid: bindPrefix + "/TestRun/StartDate"
				}
			}

			DelegateComponent {
				ListTimeSelector {
					text: CommonWords.start_time
					dataItem.uid: bindPrefix + "/TestRun/StartTime"
				}
			}

			DelegateComponent {
				preferredVisible: !runTillBatteryFullDC.checked
				ListTimeSelector {
					//% "Run duration (hh:mm)"
					text: qsTrId("page_generator_test_run_run_duration")
					dataItem.uid: bindPrefix + "/TestRun/Duration"
				}
			}

			DelegateComponent {
				id: runTillBatteryFullDC
				dataItem: VeQuickItem { uid: bindPrefix + "/TestRun/RunTillBatteryFull" }
				property bool checked: dataItem.value === 1
				preferredVisible: runTillBatteryFullItem.valid
				ListSwitch {
					id: runTillBatteryFull

					//% "Run until battery is fully charged"
					text: qsTrId("page_generator_test_run_run_until_fully_charged")
					dataItem.uid: bindPrefix + "/TestRun/RunTillBatteryFull"
				}
			}
		}
	}
}
