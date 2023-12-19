/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property var value
	property alias label: label
	property alias contentRow: contentRow
	property alias separator: separatorBar

	width: parent.width
	implicitHeight: Theme.geometry_controlCard_largeItem_height

	Label {
		id: label
		anchors {
			verticalCenter: parent.verticalCenter
			left: parent.left
			leftMargin: Theme.geometry_controlCard_contentMargins
			right: contentRow.left
			rightMargin: Theme.geometry_controlCard_contentMargins
		}

		elide: Text.ElideRight
		font.pixelSize: Theme.font_size_body1
		color: Theme.color_font_primary
	}
	Row {
		id: contentRow
		anchors {
			verticalCenter: parent.verticalCenter
			right: parent.right
			rightMargin: Theme.geometry_controlCard_contentMargins
		}

		height: parent.height
	}
	SeparatorBar {
		id: separatorBar
		anchors {
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			leftMargin: Theme.geometry_controlCard_itemSeparator_margins
			rightMargin: Theme.geometry_controlCard_itemSeparator_margins
		}

		height: visible ? implicitHeight : 0
	}
}
