/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	text: CommonWords.position_ac
	optionModel: [
		{ display: CommonWords.ac_input, value: VenusOS.AcPosition_AcInput },
		{ display: CommonWords.ac_output, value: VenusOS.AcPosition_AcOutput }
	]
}
