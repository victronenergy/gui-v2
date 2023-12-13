/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ListItem {
	id: root

	readonly property alias button: button
	property alias secondaryText: button.text

	signal clicked()

	enabled: userHasWriteAccess

	contentChildren: [
		ListItemButton {
			id: button

			enabled: root.enabled

			onClicked: root.clicked()
		}
	]
}
