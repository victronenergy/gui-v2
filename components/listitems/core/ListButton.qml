/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias button: button
	property alias secondaryText: button.text
	readonly property string __typename: "ListButton"
	property alias siblings: button.siblings
	property alias expandedClickableArea: button.expandedClickableArea
	property alias topExtent: button.topExtent
	property alias rightExtent: button.rightExtent
	property alias bottomExtent: button.bottomExtent
	property alias leftExtent: button.leftExtent

	interactive: true
	pressAreaEnabled: false

	content.children: [
		ListItemButton {
			id: button

			down: root.clickable && (pressed || checked || root.down)
			width: Math.min(implicitWidth, root.maximumContentWidth)
			showEnabled: root.clickable
			focusPolicy: Qt.NoFocus
			objectName: root.objectName + ".button" // TODO: remove

			onClicked: {
				if (!root.checkWriteAccessLevel() || !root.clickable) {
					return
				}
				root.clicked()
			}
		}
	]
}
