/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Row {
	id: root

	property int gaugeAlignmentY: Qt.AlignTop // valid values: Qt.AlignTop, Qt.AlignBottom
	property alias source: icon.source
	property alias value: quantityRow.value
	property alias physicalQuantity: quantityRow.physicalQuantity

	spacing: 4

	CP.ColorImage {
		id: icon

		anchors {
			top: root.gaugeAlignmentY === Qt.AlignBtoom ? parent.top : undefined
			bottom: root.gaugeAlignmentY === Qt.AlignTop ? parent.bottom : undefined
		}

		width: Theme.geometry.valueDisplay.icon.width
		fillMode: Image.Pad
	}
	ValueQuantityDisplay {
		id: quantityRow

		anchors {
			verticalCenter: icon.verticalCenter
		}
		font.pixelSize: Theme.font.size.l
	}
}
