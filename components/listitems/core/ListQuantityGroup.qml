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

	// Standard layout is:
	// | Primary label | Quantity row |
	// | Caption                      |
	//
	// In portrait, if the label and quantity row do not fit side-by-side, use a compact layout:
	// | Primary label |
	// | Quantity row  |
	// | Caption       |
	contentItem: GridLayout {
		readonly property bool compactLayout: Theme.screenSize === Theme.Portrait
				&& root.model?.count > 1
				&& primaryLabel.implicitWidth + quantityRow.implicitWidth > root.availableWidth

		columns: compactLayout ? 1 : 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		Label {
			id: primaryLabel

			text: root.text
			textFormat: root.textFormat
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		QuantityRow {
			id: quantityRow

			model: root.model
			Layout.alignment: Qt.AlignRight
		}

		Label {
			text: root.caption
			font.pixelSize: Theme.font_listItem_caption_size
			color: Theme.color_font_secondary
			wrapMode: Text.Wrap
			visible: text.length > 0

			Layout.columnSpan: parent.compactLayout ? 1 : 2
			Layout.maximumWidth: root.availableWidth
		}
	}
}
