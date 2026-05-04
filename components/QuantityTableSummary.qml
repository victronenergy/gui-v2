/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

/*
	A table with a header and a single row.

	This is typically used to show a summary (e.g. the total power and energy) of another table.
*/
QuantityTable {
	id: root

	property string summaryHeaderText
	property string bodyHeaderText
	property var summaryModel
	property QuantityObjectModel bodyModel

	// When true, the header is displayed above the columns, instead of next to them.
	property bool compactLayout

	bodyFontSize: Theme.font_quantityTableSummary_body_size
	model: 1
	topMargin: Theme.geometry_quantityTableSummary_verticalMargin
	bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin
	equalWidthColumns: compactLayout
	headersVisible: !compactLayout

	header: QuantityTable.TableHeader {
		headerText: root.summaryHeaderText
		model: root.summaryModel
		topPadding: headerBodyLabel.text.length || headerTitleLabel.text.length ? headerBodyLabel.height : 0

		Label {
			id: headerBodyLabel
			x: root.leftPadding
			width: root.availableWidth
			text: root.compactLayout ? root.bodyHeaderText : ""
			topPadding: headerTitleLabel.text.length ? headerTitleLabel.height : 0
			bottomPadding: Theme.geometry_quantityTableSummary_verticalMargin
			elide: Text.ElideRight
			font.pixelSize: table.bodyFontSize
			color: Theme.color_quantityTable_quantityValue

			Label {
				id: headerTitleLabel
				width: parent.width
				topPadding: Theme.geometry_quantityTableSummary_verticalMargin
				text: root.compactLayout ? root.summaryHeaderText : ""
				font.pixelSize: root.headerFontSize
				color: Theme.color_solarListPage_header_text
				elide: Text.ElideRight
			}
		}
	}

	delegate: QuantityTable.TableRow {
		implicitHeight: preferredVisible ? Theme.geometry_quantityTable_header_row_height : 0
		color: "transparent"
		headerText: root.bodyHeaderText
		headerColor: root.summaryHeaderText.length > 0 ? Theme.color_font_primary : Theme.color_quantityTable_quantityValue
		model: root.bodyModel
		valueColor: Theme.color_font_primary
	}
}
