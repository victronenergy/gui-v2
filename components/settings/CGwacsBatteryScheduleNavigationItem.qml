/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

ListNavigationItem {
	id: root

	property int scheduleNumber
	readonly property string _scheduleSource: Global.systemSettings.serviceUid + "/Settings/CGwacs/BatteryLife/Schedule/Charge/" + scheduleNumber

	property var _dayModel: [
		//% "Every day"
		{ display: qsTrId("cgwacs_battery_schedule_every_day"), value: 7 },
		//% "Weekdays"
		{ display: qsTrId("cgwacs_battery_schedule_weekdays"), value: 8 },
		//% "Weekends"
		{ display: qsTrId("cgwacs_battery_schedule_weekends"), value: 9 },
		//% "Monday"
		{ display: qsTrId("cgwacs_battery_schedule_monday"), value: 1 },
		//% "Tuesday"
		{ display: qsTrId("cgwacs_battery_schedule_tuesday"), value: 2 },
		//% "Wednesday"
		{ display: qsTrId("cgwacs_battery_schedule_wednesday"), value: 3 },
		//% "Thursday"
		{ display: qsTrId("cgwacs_battery_schedule_thursday"), value: 4 },
		//% "Friday"
		{ display: qsTrId("cgwacs_battery_schedule_friday"), value: 5 },
		//% "Saturday"
		{ display: qsTrId("cgwacs_battery_schedule_saturday"), value: 6 },
		//% "Sunday"
		{ display: qsTrId("cgwacs_battery_schedule_sunday"), value: 0 },
	]

	function dayNameForValue(v) {
		for (let i = 0; i < _dayModel.length; ++i) {
			const data = _dayModel[i]
			if (data.value === v) {
				return data.display
			}
		}
		return ""
	}

	// Negative values means disabled. We preserve the day by just flipping the sign.
	function toggleDay(v)
	{
		// Sunday (0) is special since -0 is equal, map it to -10 and vice versa.
		if (v === -10)
			return 0;
		if (v === 0)
			return -10;
		return -v
	}

	function getItemText()
	{
		if (itemDay.isValid && itemDay.value >= 0) {
			const day = dayNameForValue(itemDay.value)
			const startTimeSeconds = startTime.value || 0
			const start = ClockTime.formatTime(Math.floor(startTimeSeconds / 3600), Math.floor(startTimeSeconds % 3600 / 60))
			const durationSecs = !duration.isValid ? "--" : Utils.secondsToString(duration.value)
			if (!socLimit.isValid || socLimit.value >= 100) {
				//% "%1 %2 (%3)"
				return qsTrId("cgwacs_battery_schedule_format_no_soc").arg(day).arg(start).arg(durationSecs)
			}
			//% "%1 %2 (%3 or %4%)"
			return qsTrId("cgwacs_battery_schedule_format_soc").arg(day).arg(start).arg(durationSecs).arg("" + socLimit.value)
		}
		return CommonWords.disabled
	}

	//% "Schedule %1"
	text: qsTrId("cgwacs_battery_schedule_name").arg(scheduleNumber + 1)
	secondaryText: getItemText()

	onClicked: Global.pageManager.pushPage(scheduledOptionsComponent, { title: text })

	VeQuickItem {
		id: itemDay
		source: root._scheduleSource + "/Day"
	}

	VeQuickItem {
		id: startTime
		source: root._scheduleSource + "/Start"
	}

	VeQuickItem {
		id: duration
		source: root._scheduleSource + "/Duration"
	}

	VeQuickItem {
		id: socLimit
		source: root._scheduleSource + "/Soc"
	}

	Component {
		id: scheduledOptionsComponent

		Page {
			id: scheduledOptionsPage

			GradientListView {
				model: ObjectModel {
					ListSwitch {
						id: itemEnabled

						text: CommonWords.enabled
						checked: itemDay.isValid && itemDay.value >= 0
						onCheckedChanged: {
							if (checked ^ itemDay.value >= 0) {
								itemDay.setValue(toggleDay(itemDay.value))
							}
						}
					}

					ListRadioButtonGroup {
						//% "Day"
						text: qsTrId("cgwacs_battery_schedule_day")
						dataItem.uid: root._scheduleSource + "/Day"
						visible: defaultVisible && itemEnabled.checked
						//% "Not set"
						defaultSecondaryText: qsTrId("cgwacs_battery_schedule_day_not_set")
						optionModel: root._dayModel
					}

					ListTimeSelector {
						text: CommonWords.start_time
						dataItem.uid: root._scheduleSource + "/Start"
						visible: defaultVisible && itemEnabled.checked
					}

					ListTimeSelector {
						//% "Duration (hh:mm)"
						text: qsTrId("cgwacs_battery_schedule_duration")
						dataItem.uid: root._scheduleSource + "/Duration"
						visible: defaultVisible && itemEnabled.checked
						maximumHour: 9999
					}

					ListSpinBox {
						id: socLimitSpinBox

						//% "SOC limit"
						text: qsTrId("cgwacs_battery_schedule_soc_limit")
						visible: defaultVisible
						dataItem.uid: root._scheduleSource + "/Soc"
						suffix: "%"
						from: 5
						to: 95
						stepSize: 5
					}

					ListRadioButtonGroup {
						//% "Self-consumption above limit"
						text: qsTrId("cgwacs_battery_schedule_self_consumption_above_limit")
						dataItem.uid: root._scheduleSource + "/AllowDischarge"
						visible: defaultVisible && itemEnabled.checked && socLimit.value < 100
						optionModel: [
							//% "PV"
							{ display: qsTrId("cgwacs_battery_schedule_pv"), value: 0 },
							//% "PV & Battery"
							{ display: qsTrId("cgwacs_battery_schedule_pv_and_battery"), value: 1 }
						]
					}
				}
			}
		}
	}
}
