/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	required property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListRadioButtonGroup {
				//: EVCS AC input/output position
				//% "Position"
				text: qsTrId("evcs_ac_position")
				optionModel: [
					{
						display: CommonWords.acInput(),
						value: VenusOS.Evcs_Position_ACInput
					},
					{
						display: CommonWords.ac_output,
						value: VenusOS.Evcs_Position_ACOutput
					}
				]
				dataItem.uid: root.bindPrefix + "/Position"
			}

			ListSwitch {
				//% "Autostart"
				text: qsTrId("evcs_autostart")
				dataItem.uid: root.bindPrefix + "/AutoStart"
			}

			ListSwitch {
				//% "Lock charger display"
				text: qsTrId("evcs_lock_charger_display")
				dataItem.uid: root.bindPrefix + "/EnableDisplay"
				invertSourceValue: true
				allowed: defaultAllowed && dataItem.isValid
			}
		}
	}
}
