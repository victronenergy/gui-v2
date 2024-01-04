/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property var solarCharger

	GradientListView {
		id: chargerListView

		model: ObjectModel {
			// TODO add 'active alarms' section for this charger

			ListLabel {
				visible: lowBatteryAlarm.visible || highBatteryAlarm.visible
				leftPadding: 0
				color: Theme.color_listItem_secondaryText
				font.pixelSize: Theme.font_size_caption
				text: CommonWords.alarm_status
			}

			ListAlarm {
				id: lowBatteryAlarm

				//% "Low battery voltage alarm"
				text: qsTrId("charger_alarms_low_battery_voltage_alarm")
				dataItem.uid: root.solarCharger.serviceUid + "/Alarms/LowVoltage"
				visible: dataItem.isValid
			}

			ListAlarm {
				id: highBatteryAlarm

				//% "High battery voltage alarm"
				text: qsTrId("charger_alarms_high_battery_voltage_alarm")
				dataItem.uid: root.solarCharger.serviceUid + "/Alarms/HighVoltage"
				visible: dataItem.isValid
			}

			ListLabel {
				visible: root.solarCharger.errorModel.count > 0
				leftPadding: 0
				color: Theme.color_listItem_secondaryText
				font.pixelSize: Theme.font_size_caption
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
