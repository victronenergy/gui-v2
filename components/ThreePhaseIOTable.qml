/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

BaseListItem {
	id: root

	property int phaseCount
	property alias inputPhaseUidPrefix: inputTable.phaseUidPrefix
	property alias outputPhaseUidPrefix: outputTable.phaseUidPrefix
	property alias totalInputPowerUid: inputTable.totalPowerUid
	property alias totalOutputPowerUid: outputTable.totalPowerUid
	property int voltDecimals: Units.defaultUnitDecimals(VenusOS.Units_Volt_AC)

	implicitWidth: contentRow.implicitWidth
	implicitHeight: contentRow.implicitHeight
	background.visible: false

	Row {
		id: contentRow
		width: parent.width
		spacing: Theme.geometry_vebusDeviceListPage_quantityTable_row_spacing

		ThreePhaseQuantityTable {
			id: inputTable
			width: (parent.width - parent.spacing) / 2
			labelText: CommonWords.ac_in
			model: root.phaseCount
			voltDecimals: root.voltDecimals
		}

		ThreePhaseQuantityTable {
			id: outputTable
			width: (parent.width - parent.spacing) / 2
			labelText: CommonWords.ac_out
			model: root.phaseCount
			voltDecimals: root.voltDecimals
		}
	}
}
