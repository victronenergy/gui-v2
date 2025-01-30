/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	property alias secondaryText: button.text

	content.children: [
		ListItemButton {
			id: button

			width: Math.min(implicitWidth, root.maximumContentWidth)
			enabled: root.enabled &&
					 root.editable &&
					 root.userHasWriteAccess

			onClicked: root.clicked()
		}
	]
}
