/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	id: root

	required property string bindPrefix

	text: CommonWords.position_ac
	optionModel: [
		{ display: CommonWords.ac_input, value: VenusOS.AcPosition_AcInput },
		{ display: CommonWords.ac_output, value: VenusOS.AcPosition_AcOutput }
	]
	dataItem.uid: root.bindPrefix + "/Position"
	interactive: !positionIsAdjustable.valid || positionIsAdjustable.value === 1

	VeQuickItem {
		id: positionIsAdjustable
		uid: root.bindPrefix + "/PositionIsAdjustable"
	}
}
