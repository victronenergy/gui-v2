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

	signal clicked()

	down: pressArea.containsPress
	enabled: userHasReadAccess

	Keys.onReturnPressed: root.clicked()
	Keys.onSpacePressed: root.clicked()

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: text.length > 0
			font.pixelSize: Theme.font_size_body2
			color: Theme.color_listItem_secondaryText
			wrapMode: Text.Wrap
			width: Math.min(implicitWidth, root.maximumContentWidth - icon.width - parent.spacing)
			horizontalAlignment: Text.AlignRight
		},

		CP.ColorImage {
			id: icon

			anchors.verticalCenter: parent.verticalCenter
			source: "qrc:/images/icon_arrow_32.svg"
			rotation: 180
			color: root.containsPress ? Theme.color_listItem_down_forwardIcon : Theme.color_listItem_forwardIcon
			visible: root.enabled
		}
	]

	ListPressArea {
		id: pressArea

		radius: backgroundRect.radius
		anchors {
			fill: parent
			bottomMargin: root.spacing
		}
		onClicked: root.clicked()
	}
}
