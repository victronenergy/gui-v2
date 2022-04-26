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
		Button {
			id: button

			width: implicitWidth + 2*Theme.geometry.settingsListButton.contents.horizontalMargin
			height: Theme.geometry.settingsListButton.height
			radius: Theme.geometry.settingsListButton.radius
			flat: false
			enabled: root.userHasWriteAccess

			onClicked: root.clicked()
		}
	]
}
