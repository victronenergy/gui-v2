/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Templates as CT
import Victron.VenusOS

CT.TextField {
	id: root

	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font.size.s

	leftPadding: Theme.geometry.textField.horizontalMargin
	rightPadding: Theme.geometry.textField.horizontalMargin

	implicitWidth: contentWidth
	implicitHeight: Theme.geometry.textField.height

	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	color: Theme.color.font.primary

	background: Rectangle {
		color: Theme.color.textField.background
		border.color: Theme.color.textField.border
		radius: Theme.geometry.button.radius

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
			color: Theme.color.settingsListItem.secondaryText
		}
	}
}
