/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Repeater {
	id: root

	property int minimumDelegateWidth

	delegate: QuantityLabel {
		anchors.verticalCenter: parent.verticalCenter
		width: Math.max(implicitWidth, minimumDelegateWidth)
		font.pixelSize: Theme.font_size_body2
		value: isNaN(modelData.value) ? NaN : modelData.value
		unit: isNaN(modelData.unit) ? VenusOS.Units_None : modelData.unit
		precision: isNaN(modelData.precision) ? Units.defaultUnitPrecision(unit) : modelData.precision
		valueColor: Theme.color_quantityTable_quantityValue
		unitColor: Theme.color_quantityTable_quantityUnit

		Rectangle {
			anchors {
				right: parent.right
				rightMargin: -Theme.geometry_listItem_content_spacing / 2
			}
			width: Theme.geometry_listItem_separator_width
			height: parent.implicitHeight
			color: Theme.color_listItem_separator
			visible: model.index !== root.count - 1
		}
	}
}
