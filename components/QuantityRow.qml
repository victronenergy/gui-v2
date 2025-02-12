/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property QuantityObjectModel model
	property alias quantityMetrics: quantityMetrics
	property bool showFirstSeparator

	// In table mode, items are spaced out without separators between them.
	property bool tableMode

	readonly property bool _showSeparators: !tableMode
	readonly property int _textAlignment: tableMode ? Qt.AlignLeft : Qt.AlignHCenter

	height: Theme.geometry_listItem_height

	FontMetrics {
		id: fontMetrics
		font.pixelSize: Theme.font_size_body2
	}

	Repeater {
		id: quantityRepeater

		model: root.model
		delegate: QuantityLabel {
			id: quantityDelegate

			required property int index
			required property QuantityObject quantityObject
			readonly property real horizontalPadding: quantityObject.textValue.length ? Theme.geometry_listItem_content_spacing : 0

			width: quantityObject.textValue.length ? implicitWidth : quantityMetrics.columnWidth(unit)
			height: root.height
			leftPadding: verticalSeparator.width + horizontalPadding
			rightPadding: horizontalPadding
			alignment: root._textAlignment
			font.pixelSize: Theme.font_size_body2
			value: quantityObject.numberValue
			unit: quantityObject.unit
			precision: quantityObject.precision
			valueText: quantityObject.textValue || quantityInfo.number
			valueColor: Theme.color_quantityTable_quantityValue
			unitColor: Theme.color_quantityTable_quantityUnit

			Rectangle {
				id: verticalSeparator
				anchors.verticalCenter: parent.verticalCenter
				width: visible ? Theme.geometry_listItem_separator_width : 0
				height: fontMetrics.height
				visible: root._showSeparators
						 && (quantityDelegate.index > 0 || root.showFirstSeparator)
				color: Theme.color_listItem_separator
			}
		}
	}

	QuantityTableMetrics {
		id: quantityMetrics
		count: quantityRepeater.count
		availableWidth: root.width
		spacing: Theme.geometry_quantityGroupRow_spacing
	}
}
