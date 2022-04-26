/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias secondaryText: secondaryLabel.text
	property alias source: dataPoint.source

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: root.secondaryText.length > 0
			text: dataPoint.value || ""
			font.pixelSize: Theme.font.size.m
			color: Theme.color.settingsListItem.secondaryText
		}
	]

	DataPoint {
		id: dataPoint
	}
}
