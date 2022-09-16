/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SettingsListItem {
	id: root

	readonly property alias button: button

	signal clicked()

	content.children: [
		ListItemButton {
			id: button

			enabled: root.userHasWriteAccess

			onClicked: root.clicked()
		}
	]
}
