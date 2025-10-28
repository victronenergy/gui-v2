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
	title: qsTrId("ac_output")

	GradientListView {

		model: VisibleItemModel {

			ListSwitch {
				id: enableSwitch

				//% "Use AC Load to start/stop"
				text: qsTrId("page_generator_ac_load_use_ac_load")
				dataItem.uid: bindPrefix + "/Enabled"
			}

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

			ListSpinBox {
				id: startValue
				//% "Start when power is higher than"
				text: qsTrId("start_when_power_is_higher_than")
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/StartValue"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 5
				from: stopValue.value + stepSize
				fromErrorText: CommonWords.value_must_be_greater_than_stop_value
			}

			ListSpinBox {
				id: quietHoursStartValue
				text: CommonWords.start_value_during_quiet_hours
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/QuietHoursStartValue"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 5
				from: quietHoursStopValue.value + stepSize
				fromErrorText: CommonWords.value_must_be_greater_than_stop_value
			}

			ListSpinBox {
				id: startTime
				text: CommonWords.start_after_the_condition_is_reached_for
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/StartTimer"
				suffix: "s"
				stepSize: 1
			}

			ListSpinBox {
				id: stopValue
				//% "Stop when power is lower than"
				text: qsTrId("stop_when_power_is_lower_than")
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/StopValue"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 5
				from: 0
				to: startValue.dataItem.valid ? startValue.value - stepSize : 1000000
				toErrorText: CommonWords.value_must_be_lower_than_start_value
			}

			ListSpinBox {
				id: quietHoursStopValue
				text: CommonWords.stop_value_during_quiet_hours
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/QuietHoursStopValue"
				suffix: Units.defaultUnitString(VenusOS.Units_Watt)
				stepSize: 5
				to: quietHoursStartValue.dataItem.valid ? quietHoursStartValue.value - stepSize : 1000000
				toErrorText: CommonWords.value_must_be_lower_than_start_value
				from: 0
			}

			ListSpinBox {
				id: stopTime
				text: CommonWords.stop_after_the_condition_is_reached_for
				preferredVisible: dataItem.valid
				dataItem.uid: bindPrefix + "/StopTimer"
				suffix: "s"
				stepSize: 1
			}
		}
	}
}

