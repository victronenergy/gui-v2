/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property var solarCharger

	function _alarmTypeToText(alarmType) {
		switch (alarmType) {
		case VenusOS.SolarCharger_AlarmType_OK:
			//: Voltage alarm is at "OK" level
			//% "OK"
			return qsTrId("charger_alarms_level_ok")
		case VenusOS.SolarCharger_AlarmType_Warning:
			//: Voltage alarm is at "Warning" level
			//% "Warning"
			return qsTrId("charger_alarms_level_warning")
		case VenusOS.SolarCharger_AlarmType_Alarm:
			//: Voltage alarm is at "Alarm" level
			//% "Alarm"
			return qsTrId("charger_alarms_level_alarm")
		default:
			console.log("Unknown alarm type:", alarmType)
		}
	}

	GradientListView {
		id: chargerListView

		model: ObjectModel {
			// TODO add 'active alarms' section for this charger

			ListLabel {
				visible: lowBatteryAlarm.visible || highBatteryAlarm.visible
				leftPadding: 0
				color: Theme.color.listItem.secondaryText
				font.pixelSize: Theme.font.size.caption
				//% "Alarm Status"
				text: qsTrId("charger_alarms_header_status")
			}

			ListTextItem {
				id: lowBatteryAlarm

				//% "Low battery voltage alarm"
				text: qsTrId("charger_alarms_low_battery_voltage_alarm")
				secondaryText: dataValid ? root._alarmTypeToText(dataValue) : ""
				dataSource: root.solarCharger.serviceUid + "/Alarms/LowVoltage"
				visible: dataValid
			}

			ListTextItem {
				id: highBatteryAlarm

				//% "High battery voltage alarm"
				text: qsTrId("charger_alarms_high_battery_voltage_alarm")
				secondaryText: dataValid ? root._alarmTypeToText(dataValue) : ""
				dataSource: root.solarCharger.serviceUid + "/Alarms/HighVoltage"
				visible: dataValid
			}

			ListLabel {
				visible: root.solarCharger.errorModel.count > 0
				leftPadding: 0
				color: Theme.color.listItem.secondaryText
				font.pixelSize: Theme.font.size.caption
				//: Details of most recent errors
				//% "Last Errors"
				text: qsTrId("charger_alarms_header_last_errors")
			}

			Column {
				width: parent ? parent.width : 0

				Repeater {
					model: root.solarCharger.errorModel

					delegate: ListTextItem {
						//TODO: get error description from veutil when ChargerError is ported there (same issue as alarmmonitor.cpp)
						text: "#" + model.errorCode + " (description not available)"

						secondaryText: {
							if (root.solarCharger.errorModel.count === 1) {
								return ""
							}
							//: Details of last error
							//% "Last error"
							return model.index === 0 ? qsTrId("charger_alarm_last_error")
								  //: Details of 2nd last error
								  //% "2nd last error"
								: model.index === 1 ? qsTrId("charger_alarm_2nd_last_error")
								  //: Details of 3rd last error
								  //% "3rd last error"
								: model.index === 2 ? qsTrId("charger_alarm_3rd_last_error")
								  //: Details of 4th last error
								  //% "4th last error"
								: model.index === 3 ? qsTrId("charger_alarm_4th_last_error")
								: ""
						}
					}
				}
			}
		}
	}
}
