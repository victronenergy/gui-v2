/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property SolarCharger solarCharger

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
				allowed: dataItem.isValid
			}

			ListAlarm {
				id: highBatteryAlarm

				//% "High battery voltage alarm"
				text: qsTrId("charger_alarms_high_battery_voltage_alarm")
				dataItem.uid: root.solarCharger.serviceUid + "/Alarms/HighVoltage"
				allowed: dataItem.isValid
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
						text: ChargerError.description(model.errorCode)
						secondaryText: root.solarCharger.errorModel.count === 1 ? ""
								: CommonWords.lastErrorName(model.index)
					}
				}
			}
		}
	}
}
