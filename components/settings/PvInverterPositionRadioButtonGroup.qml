/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	text: CommonWords.position_ac
	optionModel: [
		{ display: CommonWords.ac_input_1, value: VenusOS.PvInverter_Position_ACInput },
		{ display: CommonWords.ac_input_2, value: VenusOS.PvInverter_Position_ACInput2 },
		{ display: CommonWords.ac_output, value: VenusOS.PvInverter_Position_Output },
	]
}
