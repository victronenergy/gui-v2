/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListItem {
	id: root

	readonly property alias dataItem: dataItem
	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: root.secondaryText.length > 0
			text: dataItem.value === undefined ? "" : dataItem.value
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_listItem_secondaryText
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignRight
			verticalAlignment: Text.AlignVCenter
		}
	]

	VeQuickItem {
		id: dataItem
	}
}
