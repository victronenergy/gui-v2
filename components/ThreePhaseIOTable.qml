/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	required property int phaseCount
	required property string inputPhaseUidPrefix
	required property string outputPhaseUidPrefix
	property alias totalInputPowerUid: inputTable.totalPowerUid
	property alias totalOutputPowerUid: outputTable.totalPowerUid
	property int voltDecimals: Units.defaultUnitDecimals(VenusOS.Units_Volt_AC)

	leftPadding: leftInset
	rightPadding: rightInset
	topPadding: topInset
	bottomPadding: bottomInset
	background: null

	contentItem: Flow {
		readonly property int tableWidth: Theme.screenSize === Theme.Portrait
				? root.availableWidth
				: (root.availableWidth - spacing) / 2

		spacing: Theme.geometry_vebusDeviceListPage_quantityTable_row_spacing

		ThreePhaseQuantityTable {
			id: inputTable
			width: parent.tableWidth
			labelText: CommonWords.ac_in
			labelFontSize: root.font.pixelSize
			model: root.phaseCount
			voltDecimals: root.voltDecimals
			phaseUidPrefix: root.inputPhaseUidPrefix
		}

		ThreePhaseQuantityTable {
			id: outputTable
			width: parent.tableWidth
			labelText: CommonWords.ac_out
			labelFontSize: root.font.pixelSize
			model: root.phaseCount
			voltDecimals: root.voltDecimals
			phaseUidPrefix: root.outputPhaseUidPrefix
		}
	}
}
