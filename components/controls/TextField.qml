/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS

CT.TextField {
	id: root

	property color borderColor: Theme.color_ok

	font.family: Global.fontFamily
	font.pixelSize: Theme.font_size_body2
	passwordCharacter: "\u2022"

	leftPadding: Theme.geometry_textField_horizontalMargin
	rightPadding: Theme.geometry_textField_horizontalMargin

	implicitWidth: Math.max(contentWidth, placeholderText.implicitWidth)
	implicitHeight: Theme.geometry_textField_height

	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	color: Theme.color_font_primary

	selectedTextColor: Theme.color_white
	selectionColor : Theme.color_blue
	selectByMouse: !readOnly

	background: Rectangle {
		color: "transparent"
		border.color: root.borderColor
		border.width: Theme.geometry_button_border_width
		radius: Theme.geometry_button_radius

		// QTBUG-100490 placeholderText doesn't appear in TextField if inside StackView, so
		// create our own placeholder here.
		Label {
			id: placeholderText
			anchors {
				left: parent.left
				leftMargin: root.leftPadding
				right: parent.right
				rightMargin: root.rightPadding
				verticalCenter: parent.verticalCenter
			}
			horizontalAlignment: root.horizontalAlignment
			text: root.placeholderText
			font: root.font
			elide: Text.ElideRight
			visible: root.text.length === 0 && !root.activeFocus
			color: Theme.color_listItem_secondaryText
		}
	}
}
