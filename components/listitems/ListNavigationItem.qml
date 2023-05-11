/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias secondaryText: secondaryLabel.text
	property alias secondaryLabel: secondaryLabel

	signal clicked()

	down: mouseArea.containsPress
	enabled: userHasReadAccess

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: text.length > 0
			font.pixelSize: Theme.font.size.body2
			color: Theme.color.listItem.secondaryText
			wrapMode: Text.Wrap
			horizontalAlignment: Text.AlignRight
		},

		CP.ColorImage {
			anchors.verticalCenter: parent.verticalCenter
			source: "/images/icon_back_32.svg"
			width: Theme.geometry.statusBar.button.icon.width
			height: Theme.geometry.statusBar.button.icon.height
			rotation: 180
			color: root.containsPress ? Theme.color.listItem.down.forwardIcon : Theme.color.listItem.forwardIcon
			fillMode: Image.PreserveAspectFit
			visible: root.enabled
		}
	]

	MouseArea {
		id: mouseArea
		anchors.fill: parent
		onClicked: {
			// find the gradient list view parent, and triggers its index restoration code.
			var p = root.parent
			while (p) {
				if (p.hasOwnProperty("_gradientListView_clickedIndex")) {
					p.childDelegateClicked(root)
					break
				}
				p = p.parent
			}
			// and then emit clicked as per normal
			root.clicked()
		}
	}
}
