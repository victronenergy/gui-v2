/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Templates
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

C.Button {
	id: root

	property color color: Theme.color.font.primary
	property color backgroundColor: flat ? Theme.color.button.flat.background
			: down ? Theme.color.button.outline.down.background
			: Theme.color.button.outline.background
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius

	spacing: Theme.geometry.button.spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth
	implicitHeight: contentItem.implicitHeight

	icon.color: root.color

	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font.size.s
	flat: true

	background: Rectangle {
		id: backgroundRect

		color: root.backgroundColor
		border.width: root.flat ? 0 : Theme.geometry.button.border.width
		border.color: Theme.color.button.outline.border
		radius: Theme.geometry.button.radius
	}

	contentItem: CP.IconLabel {
		anchors.fill: parent

		mirrored: root.iconAlignment === Button.AlignRight
		spacing: root.spacing
		display: root.display

		icon: root.icon
		text: root.text
		font: root.font
		color: root.color
	}
}
