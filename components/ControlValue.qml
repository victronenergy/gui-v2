/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var value
	property alias label: label
	property alias contentRow: contentRow

	width: parent.width
	implicitHeight: Theme.geometry.controlCard.largeItem.height

	Label {
		id: label

		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
			right: contentRow.left
			rightMargin: Theme.geometry.controlCard.contentMargins
		}
		elide: Text.ElideRight
		font.pixelSize: Theme.font.size.s
		color: Theme.color.font.primary
	}
	Row {
		id: contentRow
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry.controlCard.contentMargins
		}
		height: parent.height
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
