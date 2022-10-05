/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SettingsListItem {
	id: root

	property string secondaryText

	signal clicked()

	down: mouseArea.containsPress

	content.children: [
		Label {
			anchors.verticalCenter: parent.verticalCenter
			visible: root.secondaryText.length > 0
			text: root.secondaryText
			font.pixelSize: Theme.font.size.body2
			color: Theme.color.settingsListItem.secondaryText
		},

		CP.ColorImage {
			source: "/images/icon_back_32.svg"
			width: Theme.geometry.statusBar.button.icon.width
			height: Theme.geometry.statusBar.button.icon.height
			rotation: 180
			color: root.containsPress ? Theme.color.settingsListItem.down.forwardIcon : Theme.color.settingsListItem.forwardIcon
			fillMode: Image.PreserveAspectFit
			visible: root.enabled
		}
	]

	MouseArea {
		id: mouseArea

		anchors.fill: parent
		onClicked: root.clicked()
	}
}
