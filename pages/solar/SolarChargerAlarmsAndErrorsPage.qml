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
			PrimaryListLabel {
				allowed: lowBatteryAlarm.visible || highBatteryAlarm.visible || highTemperatureAlarm.visible || shortCircuitAlarm.visible
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

			ListAlarm {
				id: highTemperatureAlarm

				//% "High temperature alarm"
				text: qsTrId("charger_alarms_high_temperature_alarm")
				dataItem.uid: root.solarCharger.serviceUid + "/Alarms/HighTemperature"
				allowed: dataItem.isValid
			}

			ListAlarm {
				id: shortCircuitAlarm

				//% "Short circuit alarm"
				text: qsTrId("charger_alarms_short_circuit_alarm")
				dataItem.uid: root.solarCharger.serviceUid + "/Alarms/ShortCircuit"
				allowed: dataItem.isValid
			}

			PrimaryListLabel {
				allowed: root.solarCharger.errorCode > 0
				leftPadding: 0
				color: Theme.color_listItem_secondaryText
				font.pixelSize: Theme.font_size_caption
				//% "Active Error"
				text: qsTrId("charger_alarms_header_active_errors")
			}

			ListText {
				allowed: root.solarCharger.errorCode > 0
				text: ChargerError.description(root.solarCharger.errorCode)
			}
		}
	}
}
