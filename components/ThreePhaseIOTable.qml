/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property int phaseCount
	property alias inputPhaseUidPrefix: inputTable.phaseUidPrefix
	property alias outputPhaseUidPrefix: outputTable.phaseUidPrefix
	property alias totalInputPowerUid: inputTable.totalPowerUid
	property alias totalOutputPowerUid: outputTable.totalPowerUid

	spacing: Theme.geometry_vebusDeviceListPage_quantityTable_row_spacing

	ThreePhaseQuantityTable {
		id: inputTable
		width: (parent.width - parent.spacing) / 2
		labelText: CommonWords.ac_in
		rowCount: root.phaseCount
	}

	ThreePhaseQuantityTable {
		id: outputTable
		width: (parent.width - parent.spacing) / 2
		labelText: CommonWords.ac_out
		rowCount: root.phaseCount
	}
}
