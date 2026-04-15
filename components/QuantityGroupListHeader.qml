/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property alias headerText: firstTitleLabel.text
	property alias headerVisible: firstTitleLabel.visible
	property alias model: titleRepeater.model
	property int fontSize: Theme.font_size_caption
	readonly property int columnCount: titleRepeater.count + (headerVisible ? 1 : 0)

	// Column sizing parameters
	property int metricsFontSize: fontSize // the QuantityTableMetrics font size, for calculating column size
	property real fixedColumnWidth: NaN // if set, use this for column widths, instead of QuantityTableMetrics

	// If true and not using fixed column widths, the spacing is added as padding after the last
	// item, not just between items, to even out the header column sizes. Use this when this is
	// part of a table with headers.
	property bool padLastColumn

	height: Theme.geometry_quantityTable_row_height
	leftPadding: Theme.geometry_page_content_horizontalMargin + Theme.geometry_listItem_content_horizontalMargin
	rightPadding: Theme.geometry_page_content_horizontalMargin + Theme.geometry_listItem_content_horizontalMargin
	spacing: Theme.geometry_quantityGroupRow_spacing

	Label {
		id: firstTitleLabel
		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: root.fontSize
		color: Theme.color_solarListPage_header_text
		elide: Text.ElideRight
		width: root.fixedColumnWidth > 0 ? root.fixedColumnWidth
			: parent.width - parent.leftPadding - parent.rightPadding - quantityRow.width - root.spacing
	}

	Row {
		id: quantityRow

		anchors.verticalCenter: parent.verticalCenter

		Repeater {
			id: titleRepeater

			delegate: Label {
				width: (root.fixedColumnWidth > 0 ? root.fixedColumnWidth
						: modelData.unit === VenusOS.Units_None ? implicitWidth
						: quantityMetrics.columnWidth(modelData.unit))
					// Add spacing here instead of in Row::spacing, so that a label width can be
					// longer than width of the quantity in the table columns below, in case the
					// header is wider than the quantities.
					+ (model.index !== titleRepeater.count - 1 || root.padLastColumn ? root.spacing : 0)
				text: modelData.text
				font.pixelSize: root.fontSize
				color: Theme.color_solarListPage_header_text
				wrapMode: Text.Wrap
			}
		}

		QuantityTableMetrics {
			id: quantityMetrics
			font.pixelSize: root.metricsFontSize
		}
	}
}
