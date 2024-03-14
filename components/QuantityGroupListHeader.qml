/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	property alias firstColumnText: firstTitleLabel.text
	property alias quantityTitleModel: titleRepeater.model

	width: parent.width
	height: Theme.geometry_listItem_height

	Label {
		id: firstTitleLabel
		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin
		}
		leftPadding: Theme.geometry_listItem_content_horizontalMargin
		font.pixelSize: Theme.font_size_caption
		color: Theme.color_solarListPage_header_text
		elide: Text.ElideRight
		width: parent.width - quantityRow.width - Theme.geometry_quantityGroupRow_spacing
	}

	Row {
		id: quantityRow

		anchors {
			bottom: parent.bottom
			bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin
			right: parent.right
			rightMargin: Theme.geometry_listItem_content_horizontalMargin + Theme.geometry_icon_size_medium
		}
		width: Theme.geometry_solarListPage_quantityRow_width

		Repeater {
			id: titleRepeater

			delegate: Label {
				width: quantityMetrics.columnWidth(modelData.unit)
				text: modelData.text
				font.pixelSize: Theme.font_size_caption
				color: Theme.color_solarListPage_header_text
			}
		}

		QuantityTableMetrics {
			id: quantityMetrics
			count: titleRepeater.count
			availableWidth: quantityRow.width
			spacing: Theme.geometry_quantityGroupRow_spacing
		}
	}
}
