/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Repeater {
	id: root

	delegate: QuantityLabel {
		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: Theme.font.size.body2
		value: isNaN(modelData.value) ? NaN : modelData.value
		unit: isNaN(modelData.unit) ? Enums.Units_None : modelData.unit
		valueColor: Theme.color.quantityTable.quantityValue
		unitColor: Theme.color.quantityTable.quantityUnit

		Rectangle {
			anchors {
				right: parent.right
				rightMargin: -Theme.geometry.listItem.content.spacing / 2
			}
			width: Theme.geometry.listItem.separator.width
			height: parent.implicitHeight
			color: Theme.color.listItem.separator
			visible: model.index !== root.count - 1
		}
	}
}
