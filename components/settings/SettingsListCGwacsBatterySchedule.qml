/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListNavigationItem {
	id: root

	property int scheduleNumber
	readonly property string _scheduleSource: "com.victronenergy.settings/Settings/CGwacs/BatteryLife/Schedule/Charge/" + scheduleNumber

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
		if (itemDay.value !== undefined && itemDay.value >= 0) {
			const day = dayNameForValue(itemDay.value)
			const startTimeSeconds = startTime.value || 0
			const start = ClockTime.formatTime(Math.floor(startTimeSeconds / 3600), Math.floor(startTimeSeconds % 3600 / 60))
			const durationSecs = duration.value === undefined ? "--" : Global.secondsToString(duration.value)
			if (socLimit.value === undefined || socLimit.value >= 100) {
				//% "%1 %2 (%3)"
				return qsTrId("cgwacs_battery_schedule_format_no_soc").arg(day).arg(start).arg(durationSecs)
			}
			//% "%1 %2 (%3 or %4%)"
			return qsTrId("cgwacs_battery_schedule_format_soc").arg(day).arg(start).arg(durationSecs).arg("" + socLimit.value)
		}
		//% "Disabled"
		return qsTrId("cgwacs_battery_schedule_disabled")
	}

	//% "Schedule %1"
	text: qsTrId("cgwacs_battery_schedule_name").arg(scheduleNumber + 1)
	secondaryText: getItemText()

	onClicked: {
		Global.pageManager.pushPage(scheduledOptionsComponent, { title: text })
	}

	DataPoint {
		id: itemDay
		source: root._scheduleSource + "/Day"
	}

	DataPoint {
		id: startTime
		source: root._scheduleSource + "/Start"
	}

	DataPoint {
		id: duration
		source: root._scheduleSource + "/Duration"
	}

	DataPoint {
		id: socLimit
		source: root._scheduleSource + "/Soc"
	}

	Component {
		id: scheduledOptionsComponent

		Page {
			id: scheduledOptionsPage

			SettingsListView {
				model: ObjectModel {
					SettingsListSwitch {
						id: itemEnabled

						//% "Enabled"
						text: qsTrId("cgwacs_battery_schedule_enabled")
						checked: itemDay.value !== undefined && itemDay.value >= 0
						onCheckedChanged: {
							if (checked ^ itemDay.value >= 0) {
								itemDay.setValue(toggleDay(itemDay.value))
							}
						}
					}

					SettingsListRadioButtonGroup {
						//% "Day"
						text: qsTrId("cgwacs_battery_schedule_day")
						source: root._scheduleSource + "/Day"
						visible: defaultVisible && itemEnabled.checked
						//% "Not set"
						defaultSecondaryText: qsTrId("cgwacs_battery_schedule_day_not_set")
						model: root._dayModel

						onOptionClicked: function(index) {
							Global.pageManager.popPage(scheduledOptionsPage)
						}
					}

					SettingsListTimeSelector {
						//% "Start time"
						text: qsTrId("cgwacs_battery_schedule_start_time")
						source: root._scheduleSource + "/Start"
						visible: defaultVisible && itemEnabled.checked
					}

					SettingsListTimeSelector {
						//% "Duration (hh:mm)"
						text: qsTrId("cgwacs_battery_schedule_duration")
						source: root._scheduleSource + "/Duration"
						visible: defaultVisible && itemEnabled.checked
						maximumHour: 9999
					}

					SettingsListSwitch {
						id: socLimitEnabled

						//% "Stop on SOC"
						text: qsTrId("cgwacs_battery_schedule_stop_on_soc")
						checked: socLimitSpinBox.value < 100
						visible: defaultVisible && itemEnabled.checked

						onCheckedChanged: {
							if (checked && socLimitSpinBox.value >= 100) {
								socLimitSpinBox.dataPoint.setValue(95)
							} else if (!checked && socLimitSpinBox.value < 100) {
								socLimitSpinBox.dataPoint.setValue(100)
							}
						}
					}

					SettingsListSpinBox {
						id: socLimitSpinBox

						//% "SOC limit"
						text: qsTrId("cgwacs_battery_schedule_soc_limit")
						visible: defaultVisible && socLimitEnabled.checked
						source: root._scheduleSource + "/Soc"
						suffix: "%"
						from: 5
						to: 95
						stepSize: 5
					}
				}
			}
		}
	}
}
