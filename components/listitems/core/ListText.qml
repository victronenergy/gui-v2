/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Layouts
import Victron.VenusOS

/*
	A list setting item with additional secondary text.
*/
ListSetting {
	id: root

	readonly property alias dataItem: dataItem
	property string secondaryText: dataItem.valid ? dataItem.value : ""
	property color secondaryTextColor: Theme.color_listItem_secondaryText

	// Layout has 2 columns, 2 rows. The caption spans across both columns.
	// | Primary label | Secondary label |
	// | Caption                         |
	contentItem: GridLayout {
		columns: 2
		columnSpacing: root.spacing
		rowSpacing: Theme.geometry_listItem_content_verticalSpacing

		Label {
			text: root.text
			font: root.font
			wrapMode: Text.Wrap

			Layout.fillWidth: true
		}

		SecondaryListLabel {
			text: root.secondaryText

			Layout.fillWidth: true
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

	VeQuickItem {
		id: dataItem
	}
}
