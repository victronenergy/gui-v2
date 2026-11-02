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
	property color secondaryTextColor: Theme.color_font_secondary

	contentItem: ListItemLabelLayout {
		primaryText: root.text
		primaryLabel.font: root.font
		primaryLabel.textFormat: root.textFormat
		secondaryText: root.secondaryText
		secondaryLabel.color: root.secondaryTextColor
	}

	VeQuickItem {
		id: dataItem
	}
}
