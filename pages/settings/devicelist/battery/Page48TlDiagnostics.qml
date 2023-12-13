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

				contentChildren: [
					Repeater {
						model: [
							{ servicePath: "/Diagnostics/LedStatus/Green", color: "#00FF00" },
							{ servicePath: "/Diagnostics/LedStatus/Amber", color: "#FFBF00" },
							{ servicePath: "/Diagnostics/LedStatus/Blue", color: "#0000FF" },
							{ servicePath: "/Diagnostics/LedStatus/Red", color: "#FF0000" },
						]
						delegate: Led {
							dataSource: root.bindPrefix + modelData.servicePath
							color: modelData.color
						}
					}
				]
			}

			ListTextItem {
				//% "Alarm"
				text: qsTrId("batterydiagnostics_alarm")
				dataSource: root.bindPrefix + "/Diagnostics/IoStatus/AlarmOutActive"
				secondaryText: dataValue
						 //: Indicates no alarm is set
						 //% "None"
					   ? qsTrId("batterydiagnostics_none")
					   : CommonWords.active_status
			}

			ListTextItem {
				//% "Main Switch"
				text: qsTrId("batterydiagnostics_main_switch")
				dataSource: root.bindPrefix + "/Diagnostics/IoStatus/MainSwitchClosed"
				secondaryText: dataValue ? CommonWords.closed_status : CommonWords.open_status
			}

			ListTextItem {
				//% "Heater"
				text: qsTrId("batterydiagnostics_heater")
				dataSource: root.bindPrefix + "/Diagnostics/IoStatus/HeaterOn"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Internal Fan"
				text: qsTrId("batterydiagnostics_internal_fan")
				dataSource: root.bindPrefix + "/Diagnostics/IoStatus/InternalFanActive"
				secondaryText: CommonWords.onOrOff(dataValue)
			}

			ListTextItem {
				//% "Warning Flags"
				text: qsTrId("batterydiagnostics_warning_flags")
				dataSource: root.bindPrefix + "/Diagnostics/WarningFlags"
			}

			ListTextItem {
				//% "Alarm Flags"
				text: qsTrId("batterydiagnostics_alarm_flags")
				dataSource: root.bindPrefix + "/Diagnostics/AlarmFlags"
			}
		}
	}
}
