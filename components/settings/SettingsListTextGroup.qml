/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

SettingsListItem {
	id: root

	property alias model: repeater.model

	enabled: false

	content.children: [
		Repeater {
			id: repeater

			delegate: Label {
				id: label
				anchors.verticalCenter: parent.verticalCenter
				width: separator.visible
					   ? implicitWidth + Theme.geometry.settingsListItem.content.spacing
					   : implicitWidth
				font.pixelSize: Theme.font.size.m
				color: Theme.color.settingsListItem.secondaryText
				text: modelData

				Rectangle {
					id: separator

					x: label.implicitWidth + Theme.geometry.settingsListItem.content.spacing
					width: Theme.geometry.settingsListItem.separator.width
					height: parent.implicitHeight
					color: Theme.color.settingsListItem.separator
					visible: model.index !== repeater.count - 1
				}
			}
		}
	]
}
