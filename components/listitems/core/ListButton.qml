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

	// If true, displays a text label instead of a button.
	property bool readOnly: false

	interactive: true
	pressAreaEnabled: false

	content.children: [
		ListItemButton {
			id: button

			// TODO increase the button press area (see #2768). Can do this more easily without
			// affecting the content geometry, when ListItem is changed to be a Control, and this
			// type can implement its own layout.

			down: root.clickable && (pressed || checked || root.down)
			width: Math.min(implicitWidth, root.maximumContentWidth)
			showEnabled: root.clickable
			focusPolicy: Qt.NoFocus
			visible: !root.readOnly

			onClicked: {
				if (!root.checkWriteAccessLevel() || !root.clickable) {
					return
				}
				root.clicked()
			}
		},

		SecondaryListLabel {
			text: button.text
			width: Math.min(implicitWidth, root.maximumContentWidth)
			visible: !button.visible
		}
	]
}
