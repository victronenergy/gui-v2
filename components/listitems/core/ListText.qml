/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel

	content.children: [
		SecondaryListLabel {
			id: secondaryLabel
			text: dataItem.valid ? dataItem.value : ""
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: text.length > 0
		}
	]

	VeQuickItem {
		id: dataItem
	}
}
