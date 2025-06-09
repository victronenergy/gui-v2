/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Row {
	id: root

	property alias headerText: firstTitleLabel.text
	property alias model: titleRepeater.model
	property int fontSize: Theme.font_size_caption
	readonly property int columnCount: titleRepeater.count + 1 // +1 for header column

	// Column sizing parameters
	property int metricsFontSize: fontSize // the QuantityTableMetrics font size, for calculating column size
	property real fixedColumnWidth: NaN // if set, use this for column widths, instead of QuantityTableMetrics

	height: Theme.geometry_quantityTable_row_height
	leftPadding: Theme.geometry_listItem_content_horizontalMargin
	rightPadding: Theme.geometry_listItem_content_horizontalMargin
	spacing: Theme.geometry_quantityGroupRow_spacing

	Label {
		id: firstTitleLabel
		anchors.verticalCenter: parent.verticalCenter
		font.pixelSize: root.fontSize
		color: Theme.color_solarListPage_header_text
		elide: Text.ElideRight
		width: isNaN(root.fixedColumnWidth)
			   ? parent.width - parent.leftPadding - parent.rightPadding - quantityRow.width - root.spacing
			   : root.fixedColumnWidth
	}

	Row {
		id: quantityRow

		anchors.verticalCenter: parent.verticalCenter
		spacing: root.spacing

		Repeater {
			id: titleRepeater

			delegate: Label {
				width: isNaN(root.fixedColumnWidth)
					   ? quantityMetrics.columnWidth(modelData.unit, implicitWidth)
					   : root.fixedColumnWidth
				text: modelData.text
				font.pixelSize: root.fontSize
				color: Theme.color_solarListPage_header_text
			}
		}

		QuantityTableMetrics {
			id: quantityMetrics
			font.pixelSize: root.metricsFontSize
		}
	}
}
