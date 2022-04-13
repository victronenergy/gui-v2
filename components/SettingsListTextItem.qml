/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib

SettingsListItem {
	id: root

	property alias secondaryText: secondaryLabel.text
	property string source
	readonly property alias veItem: veItem

	content.children: [
		Label {
			id: secondaryLabel

			anchors.verticalCenter: parent.verticalCenter
			visible: root.secondaryText.length > 0
			text: veItem.value || ""
			font.pixelSize: Theme.font.size.m
			color: Theme.color.settingsListItem.secondaryText
		}
	]

	VeQuickItem {
		id: veItem
		uid: source.length > 0 && dbusConnected ? "dbus/" + source : ""
	}
}
