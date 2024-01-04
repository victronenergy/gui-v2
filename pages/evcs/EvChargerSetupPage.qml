/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
				dataItem.uid: root.evCharger.serviceUid + "/MaxCurrent"
				presets: Global.evChargers.maxCurrentPresets
			}

			ListRadioButtonGroup {
				//: EVCS AC input/output position
				//% "Position"
				text: qsTrId("evcs_ac_position")
				optionModel: [
					{
						display: CommonWords.ac_input,
						value: VenusOS.Evcs_Position_ACInput
					},
					{
						display: CommonWords.ac_output,
						value: VenusOS.Evcs_Position_ACOutput
					}
				]
				dataItem.uid: root.evCharger.serviceUid + "/Position"
			}

			ListSwitch {
				//% "Auto start"
				text: qsTrId("evcs_auto_start")
				dataItem.uid: root.evCharger.serviceUid + "/AutoStart"
			}

			ListSwitch {
				//% "Lock charger display"
				text: qsTrId("evcs_lock_charger_display")
				dataItem.uid: root.evCharger.serviceUid + "/EnableDisplay"
				invertSourceValue: true
			}
		}
	}
}
