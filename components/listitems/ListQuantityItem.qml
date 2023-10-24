/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	property alias dataSource: dataPoint.source
	readonly property alias dataValue: dataPoint.value
	readonly property alias dataValid: dataPoint.valid
	property alias dataInvalidate: dataPoint.invalidate
	function setDataValue(v) { dataPoint.setValue(v) }

	property alias value: quantityLabel.value
	property alias unit: quantityLabel.unit
	property alias precision: quantityLabel.precision

	content.children: [
		QuantityLabel {
			id: quantityLabel

			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: Theme.font.size.body2
			value: dataPoint.value === undefined ? NaN : dataPoint.value
		}
	]

	DataPoint {
		id: dataPoint
	}
}
