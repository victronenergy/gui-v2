/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var value
	property alias label: label
	property alias button: button

	signal clicked()

	height: Theme.geometry.controlCard.largeItem.height

	Label {
		id: label

		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
			right: button.left
			rightMargin: Theme.geometry.controlCard.contentMargins
		}
		elide: Text.ElideRight
		font.pixelSize: Theme.font.size.s
		color: Theme.color.font.primary
	}
	Button {
		id: button
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry.controlCard.contentMargins
		}
		height: Theme.geometry.essCard.minimumSocButton.height
		width: Theme.geometry.essCard.minimumSocButton.width

		flat: false
		color: Theme.color.font.primary
		border.color: Theme.color.ok
		font.pixelSize: Theme.font.size.m

		onClicked: root.clicked()
	}
	SeparatorBar {
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			leftMargin: Theme.geometry.controlCard.itemSeparator.margins
			rightMargin: Theme.geometry.controlCard.itemSeparator.margins
		}
	}
}
