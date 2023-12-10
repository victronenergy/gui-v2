/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Row {
	id: root

	property int numberOfPhases
	property DataPoint acActiveInputPower
	property DataPoint acOutputPower
	property var inputPhases
	property var outputPhases

	spacing: Theme.geometry.vebusDeviceListPage.quantityTable.row.spacing

	ThreePhaseQuantityTable {
		numberOfPhases: root.numberOfPhases
		acPhases: root.inputPhases
		width: (parent.width - parent.spacing) / 2
		labelText: CommonWords.ac_in
		totalPower: Units.getDisplayText(VenusOS.Units_Watt, acActiveInputPower.value)
	}

	ThreePhaseQuantityTable {
		numberOfPhases: root.numberOfPhases
		acPhases: root.outputPhases
		width: (parent.width - parent.spacing) / 2
		labelText: CommonWords.ac_out
		totalPower: Units.getDisplayText(VenusOS.Units_Watt, acOutputPower.value)
	}
}
