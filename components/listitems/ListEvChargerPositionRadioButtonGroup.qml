/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	//: EVCS AC input/output position
	//% "Position"
	text: qsTrId("evcs_ac_position")
	optionModel: [
		{ display: CommonWords.ac_input, value: VenusOS.Evcs_Position_ACInput },
		{ display: CommonWords.ac_output, value: VenusOS.Evcs_Position_ACOutput }
	]
}
