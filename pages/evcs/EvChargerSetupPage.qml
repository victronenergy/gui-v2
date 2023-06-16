/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property var evCharger

	GradientListView {
		model: ObjectModel {
			ListSpinBox {
				//% "Max charging current"
				text: qsTrId("evcs_max_charging_current")
				suffix: "A"
				dataSource: root.evCharger.serviceUid + "/MaxCurrent"
				presets: Global.evChargers.maxCurrentPresets
			}

			ListRadioButtonGroup {
				text: CommonWords.mode
				optionModel: [
					{
						//% "AC Input"
						display: qsTrId("evcs_position_ac_input"),
						value: VenusOS.Evcs_Position_ACInput
					},
					{
						//% "AC Output"
						display: qsTrId("evcs_position_ac_output"),
						value: VenusOS.Evcs_Position_ACOutput
					}
				]
				dataSource: root.evCharger.serviceUid + "/Position"
			}

			ListSwitch {
				//% "Auto start"
				text: qsTrId("evcs_auto_start")
				dataSource: root.evCharger.serviceUid + "/AutoStart"
			}

			ListSwitch {
				//% "Lock charger display"
				text: qsTrId("evcs_lock_charger_display")
				dataSource: root.evCharger.serviceUid + "/EnableDisplay"
				invertSourceValue: true
			}
		}
	}
}
