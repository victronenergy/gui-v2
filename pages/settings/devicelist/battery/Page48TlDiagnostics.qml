/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListItem {
				//% "Status LEDs"
				text: qsTrId("batterydiagnostics_status_leds")

				content.children: [
					Repeater {
						model: [
							{ servicePath: "/Diagnostics/LedStatus/Green", color: "#00FF00" },
							{ servicePath: "/Diagnostics/LedStatus/Amber", color: "#FFBF00" },
							{ servicePath: "/Diagnostics/LedStatus/Blue", color: "#0000FF" },
							{ servicePath: "/Diagnostics/LedStatus/Red", color: "#FF0000" },
						]
						delegate: Led {
							dataItem.uid: root.bindPrefix + modelData.servicePath
							color: modelData.color
						}
					}
				]
			}

			ListTextItem {
				text: CommonWords.alarm
				dataItem.uid: root.bindPrefix + "/Diagnostics/IoStatus/AlarmOutActive"
				secondaryText: dataItem.value
						 //: Indicates no alarm is set
						 //% "None"
					   ? qsTrId("batterydiagnostics_none")
					   : CommonWords.active_status
			}

			ListTextItem {
				//% "Main Switch"
				text: qsTrId("batterydiagnostics_main_switch")
				dataItem.uid: root.bindPrefix + "/Diagnostics/IoStatus/MainSwitchClosed"
				secondaryText: dataItem.value ? CommonWords.closed_status : CommonWords.open_status
			}

			ListTextItem {
				//% "Heater"
				text: qsTrId("batterydiagnostics_heater")
				dataItem.uid: root.bindPrefix + "/Diagnostics/IoStatus/HeaterOn"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "Internal Fan"
				text: qsTrId("batterydiagnostics_internal_fan")
				dataItem.uid: root.bindPrefix + "/Diagnostics/IoStatus/InternalFanActive"
				secondaryText: CommonWords.onOrOff(dataItem.value)
			}

			ListTextItem {
				//% "Warning Flags"
				text: qsTrId("batterydiagnostics_warning_flags")
				dataItem.uid: root.bindPrefix + "/Diagnostics/WarningFlags"
			}

			ListTextItem {
				//% "Alarm Flags"
				text: qsTrId("batterydiagnostics_alarm_flags")
				dataItem.uid: root.bindPrefix + "/Diagnostics/AlarmFlags"
			}
		}
	}
}
