/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel
	property alias icon: icon

	interactive: true
	Keys.onRightPressed: root.activate()

	// Issue #1964: userHasWriteAccess is ignored for ListNavigation - see ListItem

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: text.length > 0
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_listItem_secondaryText
			wrapMode: Text.Wrap
			width: Math.min(implicitWidth, root.maximumContentWidth - icon.width - root.content.spacing)
			horizontalAlignment: Text.AlignRight
		},

		CP.ColorImage {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: root.down ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
			visible: root.interactive
		}
	]
}
