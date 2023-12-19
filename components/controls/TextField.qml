/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS

CT.TextField {
	id: root

	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font_size_body2

	leftPadding: Theme.geometry_textField_horizontalMargin
	rightPadding: Theme.geometry_textField_horizontalMargin

	implicitWidth: contentWidth
	implicitHeight: Theme.geometry_textField_height

	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	color: Theme.color_font_primary

	background: Rectangle {
		color: "transparent"
		border.color: Theme.color_ok
		border.width: Theme.geometry_button_border_width
		radius: Theme.geometry_button_radius

		// QTBUG-100490 placeholderText doesn't appear in TextField if inside StackView, so
		// create our own placeholder here.
		Label {
			anchors {
				left: parent.left
				leftMargin: root.leftPadding
				right: parent.right
				rightMargin: root.rightPadding
				verticalCenter: parent.verticalCenter
			}
			horizontalAlignment: Text.AlignHCenter
			text: root.placeholderText
			font: root.font
			visible: root.text.length === 0 && !root.activeFocus
			color: Theme.color_listItem_secondaryText
		}
	}
}
