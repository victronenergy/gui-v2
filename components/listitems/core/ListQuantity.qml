/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias value: quantityLabel.value
	property alias unit: quantityLabel.unit
	property alias precision: quantityLabel.precision

	content.children: [
		QuantityLabel {
			id: quantityLabel

			anchors.verticalCenter: parent.verticalCenter
			font.pixelSize: Theme.font_size_body2
			value: dataItem.valid ? dataItem.value : NaN
		}
	]

	VeQuickItem {
		id: dataItem
	}
}
