/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	//% "AC output"

	VeQuickItem {
		id: stopTimerItem
		uid: bindPrefix + "/StopTimer"
	}
	VeQuickItem {
		id: quietHoursStopValueItem
		uid: bindPrefix + "/QuietHoursStopValue"
	}
	VeQuickItem {
		id: stopValueItem
		uid: bindPrefix + "/StopValue"
	}
	VeQuickItem {
		id: startTimerItem
		uid: bindPrefix + "/StartTimer"
	}
	VeQuickItem {
		id: quietHoursStartValueItem
		uid: bindPrefix + "/QuietHoursStartValue"
	}
	VeQuickItem {
		id: startValueItem
		uid: bindPrefix + "/StartValue"
	}

	title: qsTrId("ac_output")

	GradientListView {

		model: DelegateComponentModel {

			DelegateComponent {
				ListSwitch {
					id: enableSwitch

					//% "Use AC Load to start/stop"
					text: qsTrId("page_generator_ac_load_use_ac_load")
					dataItem.uid: bindPrefix + "/Enabled"
				}
			}

			DelegateComponent {
				ListRadioButtonGroup {
					//% "Measurement"
					text: qsTrId("page_generator_ac_load_measurement")
					dataItem.uid: bindPrefix + "/Measurement"
					optionModel: [
						//% "Total consumption"
						{ display: qsTrId("total_consumption"), value: 0 },
						//% "Inverter total AC out"
						{ display: qsTrId("total_ac_out"), value: 1 },
						//% "Inverter AC out highest phase"
						{ display: qsTrId("ac_out_highest_phase"), value: 2 },
					]
				}
			}

			DelegateComponent {
				preferredVisible: startValueItem.valid
				ListSpinBox {
					id: startValue
					//% "Start when power is higher than"
					text: qsTrId("start_when_power_is_higher_than")
					dataItem.uid: bindPrefix + "/StartValue"
					suffix: Units.defaultUnitString(VenusOS.Units_Watt)
					stepSize: 5
					from: stopValueItem.valid ? stopValueItem.value + stepSize : dataItem.defaultMin
					fromErrorText: CommonWords.value_must_be_greater_than_stop_value
				}
			}

			DelegateComponent {
				preferredVisible: quietHoursStartValueItem.valid
				ListSpinBox {
					id: quietHoursStartValue
					text: CommonWords.start_value_during_quiet_hours
					dataItem.uid: bindPrefix + "/QuietHoursStartValue"
					suffix: Units.defaultUnitString(VenusOS.Units_Watt)
					stepSize: 5
					from: quietHoursStopValueItem.valid ? quietHoursStopValueItem.value + stepSize : dataItem.defaultMin
					fromErrorText: CommonWords.value_must_be_greater_than_stop_value
				}
			}

			DelegateComponent {
				preferredVisible: startTimerItem.valid
				ListSpinBox {
					id: startTime
					text: CommonWords.start_after_the_condition_is_reached_for
					dataItem.uid: bindPrefix + "/StartTimer"
					suffix: "s"
					stepSize: 1
				}
			}

			DelegateComponent {
				preferredVisible: stopValueItem.valid
				ListSpinBox {
					id: stopValue
					//% "Stop when power is lower than"
					text: qsTrId("stop_when_power_is_lower_than")
					dataItem.uid: bindPrefix + "/StopValue"
					suffix: Units.defaultUnitString(VenusOS.Units_Watt)
					stepSize: 5
					from: 0
					to: startValueItem.valid ? startValueItem.value - stepSize : 1000000
					toErrorText: CommonWords.value_must_be_lower_than_start_value
				}
			}

			DelegateComponent {
				preferredVisible: quietHoursStopValueItem.valid
				ListSpinBox {
					id: quietHoursStopValue
					text: CommonWords.stop_value_during_quiet_hours
					dataItem.uid: bindPrefix + "/QuietHoursStopValue"
					suffix: Units.defaultUnitString(VenusOS.Units_Watt)
					stepSize: 5
					to: quietHoursStartValueItem.valid ? quietHoursStartValueItem.value - stepSize : 1000000
					toErrorText: CommonWords.value_must_be_lower_than_start_value
					from: 0
				}
			}

			DelegateComponent {
				preferredVisible: stopTimerItem.valid
				ListSpinBox {
					id: stopTime
					text: CommonWords.stop_after_the_condition_is_reached_for
					dataItem.uid: bindPrefix + "/StopTimer"
					suffix: "s"
					stepSize: 1
				}
			}
		}
	}
}
