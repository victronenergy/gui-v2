/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property QuantityObjectModel model
	property bool showFirstSeparator
	property int fontSize: Theme.font_size_body2
	property color valueColor: Theme.color_quantityTable_quantityValue
	readonly property int count: quantityRepeater.count

	// Column sizing and alignment parameters
	property bool tableMode // if true, items are spaced out without separators in between
	property int metricsFontSize: fontSize // the QuantityTableMetrics font size, for calculating column size
	property real fixedColumnWidth: NaN // if set, use this for column widths, instead of QuantityTableMetrics
	property int labelAlignment: tableMode ? Qt.AlignLeft : Qt.AlignHCenter

	readonly property bool _showSeparators: !tableMode

	spacing: Theme.geometry_quantityGroupRow_spacing

	FontMetrics {
		id: fontMetrics
		font.pixelSize: root.fontSize
	}

	Repeater {
		id: quantityRepeater

		model: root.model
		delegate: QuantityLabel {
			id: quantityDelegate

			required property int index
			required property QuantityObject quantityObject
			readonly property real horizontalPadding: root._showSeparators ? Theme.geometry_listItem_content_spacing : 0

			width: !isNaN(root.fixedColumnWidth) ? root.fixedColumnWidth
				: quantityObject.unit === VenusOS.Units_None ? implicitWidth
				: quantityMetrics.columnWidth(quantityObject.unit) + horizontalPadding
			leftPadding: horizontalPadding
					+ (verticalSeparator.visible ? verticalSeparator.width : 0)
					+ (root._showSeparators ? root.spacing : 0) // offset the space to the previous item
			rightPadding: horizontalPadding
			alignment: root.labelAlignment
			opacity: quantityObject.hidden ? 0 : 1
			font.pixelSize: root.fontSize
			value: quantityObject.numberValue
			unit: quantityObject.unit
			precision: quantityObject.precision
			valueText: unit === VenusOS.Units_PowerFactor ? "PF" : (quantityObject.textValue || quantityInfo.number)
			unitText: unit === VenusOS.Units_PowerFactor ? (quantityObject.textValue || quantityInfo.number) : quantityInfo.unit
			valueColor: unit === VenusOS.Units_PowerFactor ? Theme.color_quantityTable_quantityUnit
				: quantityObject.valueColor.valid ? quantityObject.valueColor
				: root.valueColor
			unitColor: unit !== VenusOS.Units_PowerFactor ? Theme.color_quantityTable_quantityUnit
				: quantityObject.valueColor.valid ? quantityObject.valueColor
				: root.valueColor

			Rectangle {
				id: verticalSeparator
				anchors.verticalCenter: parent.verticalCenter
				width: Theme.geometry_listItem_separator_width
				height: fontMetrics.height
				visible: root._showSeparators
						 && (quantityDelegate.index > 0 || root.showFirstSeparator)
				color: Theme.color_listItem_separator
			}
		}
	}

	QuantityTableMetrics {
		id: quantityMetrics
		font.pixelSize: root.metricsFontSize
	}
}
