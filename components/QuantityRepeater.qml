/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Repeater {
	id: root

	property int minimumDelegateWidth

	delegate: Row {
		QuantityLabel {
			anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
			visible: !textLabel.visible
			width: Math.max(implicitWidth, minimumDelegateWidth)
			alignment: Qt.AlignHCenter
			font.pixelSize: Theme.font_size_body2
			value: isNaN(modelData.value) ? NaN : modelData.value
			unit: modelData.unit === undefined ? VenusOS.Units_None : modelData.unit
			precision: isNaN(modelData.precision) ? Units.defaultUnitPrecision(unit) : modelData.precision
			valueColor: Theme.color_quantityTable_quantityValue
			unitColor: Theme.color_quantityTable_quantityUnit
		}

		// Show a plain label instead of a QuantityLabel if modelData.value is a string instead of
		// a number.
		Label {
			id: textLabel
			anchors.verticalCenter: !!parent ? parent.verticalCenter : undefined
			visible: typeof(modelData.value) === 'string'
			text: visible ? modelData.value : ""
			width: Math.max(implicitWidth, minimumDelegateWidth)
			horizontalAlignment: Qt.AlignHCenter
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_quantityTable_quantityValue
		}

		Item {
			width: Theme.geometry_listItem_separator_width + (Theme.geometry_listItem_content_spacing * 2)
			height: parent.implicitHeight
			visible: model.index !== root.count - 1

			Rectangle {
				anchors.horizontalCenter: parent.horizontalCenter
				width: Theme.geometry_listItem_separator_width
				height: parent.height
				color: Theme.color_listItem_separator
			}
		}
	}
}
