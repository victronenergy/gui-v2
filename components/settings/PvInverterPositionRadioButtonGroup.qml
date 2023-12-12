/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	text: CommonWords.position_ac
	optionModel: [
		{ display: CommonWords.ac_input_1, value: Enums.PvInverter_Position_ACInput },
		{ display: CommonWords.ac_input_2, value: Enums.PvInverter_Position_ACInput2 },
		{ display: CommonWords.ac_output, value: Enums.PvInverter_Position_Output },
	]
}
