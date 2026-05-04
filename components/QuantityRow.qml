/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property QuantityObjectModel model
	property int fontSize: Theme.font_listItem_secondary_size
	property color valueColor: Theme.color_quantityTable_quantityValue
	readonly property int count: quantityRepeater.count

	// Column sizing and alignment parameters
	property bool tableMode // if true, items are spaced out without separators in between
	property int metricsFontSize: fontSize // the QuantityTableMetrics font size, for calculating column size
	property real fixedColumnWidth: NaN // if set, use this for column widths, instead of QuantityTableMetrics
	property int labelAlignment: tableMode ? Qt.AlignLeft : Qt.AlignHCenter

	// If true and not using fixed column widths, the spacing is added as padding after the last
	// item, not just between items, to even out the header column sizes. Use this when this is
	// part of a table with headers.
	property bool padLastColumn

	readonly property bool _showSeparators: !tableMode

	spacing: Theme.geometry_quantityGroupRow_spacing

	Repeater {
		id: quantityRepeater

		model: root.model
		delegate: QuantityLabel {
			id: quantityDelegate

			required property int index
			required property QuantityObject quantityObject

			width: root.fixedColumnWidth > 0 ? root.fixedColumnWidth
				: quantityObject.unit === VenusOS.Units_None ? implicitWidth
				: quantityMetrics.columnWidth(quantityObject.unit)
						+ (root.padLastColumn && index === root.model.count - 1 ? root.spacing : 0)
			leftPadding: (verticalSeparator.visible ? Theme.geometry_listItem_separator_width : 0)
					+ (root._showSeparators ? root.spacing : 0) // offset the space to the previous item
			alignment: root.labelAlignment
			opacity: quantityObject.hidden ? 0 : 1
			font.pixelSize: root.fontSize
			value: quantityObject.numberValue
			unit: quantityObject.unit
			decimals: quantityObject.decimals
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
				height: quantityMetrics.height
				visible: root._showSeparators && quantityDelegate.index > 0
				color: Theme.color_listItem_separator
			}
		}
	}

	QuantityTableMetrics {
		id: quantityMetrics
		font.pixelSize: root.metricsFontSize
	}
}
