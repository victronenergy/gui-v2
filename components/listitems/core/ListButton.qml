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

			down: pressed || checked || root.down
			width: Math.min(implicitWidth, root.maximumContentWidth)
			enabled: root.clickable
			focusPolicy: Qt.NoFocus

			onClicked: root.clicked()
		}
	]
}
