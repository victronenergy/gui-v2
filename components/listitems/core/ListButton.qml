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

	interactive: true
	pressAreaEnabled: false

	content.children: [
		ListItemButton {
			id: button

			down: root.clickable && (pressed || checked || root.down)
			width: Math.min(implicitWidth, root.maximumContentWidth)
			showEnabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: {
				if (!root.checkWriteAccessLevel() || !root.clickable) {
					return
				}
				root.clicked()
			}
		}
	]
}
