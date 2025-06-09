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

	bodyFontSize: Theme.font_size_body3
	model: 1
	topMargin: Theme.geometry_quantityTableSummary_verticalMargin
	bottomMargin: Theme.geometry_quantityTableSummary_verticalMargin

	header: QuantityTable.TableHeader {
		headerText: root.summaryHeaderText
		model: root.summaryModel
	}

	delegate: QuantityTable.TableRow {
		color: "transparent"
		headerText: root.bodyHeaderText
		headerColor: root.summaryHeaderText.length > 0 ? Theme.color_font_primary : Theme.color_quantityTable_quantityValue
		model: root.bodyModel
		valueColor: Theme.color_font_primary
	}
}
