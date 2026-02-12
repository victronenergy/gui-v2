/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

ListSetting {
	id: root

	property QuantityObjectModel model

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Quantity row |
	// | Caption                      |
	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		Label {
			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		QuantityRow {
			model: root.model
			Layout.alignment: Qt.AlignRight
		}

		Label {
			text: root.caption
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: 2
			Layout.maximumWidth: root.availableWidth
		}
	}
}
