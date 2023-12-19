/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Units

Item {
	id: root

	property real value
	property int unit: VenusOS.Units_None
	property alias font: valueLabel.font
	property alias valueColor: valueLabel.color
	property alias unitColor: unitLabel.color
	property int alignment: Qt.AlignHCenter
	property int precision: Units.defaultUnitPrecision(unit)

	readonly property var _quantity: unit === VenusOS.Units_None
		 ? undefined
		 : Units.getDisplayText(unit, value, precision)

	// Restrict the height to the baseline to help align the baseline of labels in different
	// QuantityLabel items with different font sizes. E.g. Environments tab may have multiple gauges
	// with different font sizes, that need to align side-by-side at the font baseline.
	implicitWidth: valueLabel.implicitWidth + Theme.geometry_quantityLabel_spacing + unitLabel.implicitWidth
	implicitHeight: Math.ceil(valueLabel.baselineOffset) + Theme.geometry_quantityLabel_bottomMargin

	Label {
		id: valueLabel

		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: root.alignment === Qt.AlignHCenter ? parent.horizontalCenter : undefined
			horizontalCenterOffset: -(unitLabel.width + Theme.geometry_quantityLabel_spacing)/2
			left: root.alignment === Qt.AlignLeft ? parent.left : undefined
			right: root.alignment === Qt.AlignRight ? parent.right : undefined
			rightMargin: unitLabel.width
		}
		color: Theme.color_font_primary
		text: root._quantity === undefined ? "" : root._quantity.number
		width: Math.min(implicitWidth, root.width - unitLabel.width - Theme.geometry_quantityLabel_spacing)
		elide: Text.ElideRight
	}

	Label {
		id: unitLabel

		anchors {
			verticalCenter: parent.verticalCenter
			left: valueLabel.right
			leftMargin: Theme.geometry_quantityLabel_spacing
		}
		text: root.unit === VenusOS.Units_None ? "" : root._quantity.unit
		font: valueLabel.font
		color: Theme.color_font_secondary
	}
}
