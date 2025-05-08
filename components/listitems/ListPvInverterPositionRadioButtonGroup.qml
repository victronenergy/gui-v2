/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	text: CommonWords.position_ac
	optionModel: [
		{ display: CommonWords.acInputFromNumber(1), value: VenusOS.PvInverter_Position_ACInput },
		{ display: CommonWords.acInputFromNumber(2), value: VenusOS.PvInverter_Position_ACInput2 },
		{ display: CommonWords.ac_output, value: VenusOS.PvInverter_Position_ACOutput },
	]
}
