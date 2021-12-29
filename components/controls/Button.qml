/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

CT.Button {
	id: root

	property color color: enabled ? Theme.color.font.primary : Theme.color.font.disabled
	property color backgroundColor: !enabled ? Theme.color.background.disabled
			: down ? downColor
			: flat ? Theme.color.button.flat.background
			: Theme.color.button.outline.background
	property color downColor: flat ? Theme.color.button.flat.background
			: Theme.color.button.outline.down.background
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius
	property alias roundedSide: backgroundRect.roundedSide

	down: pressed || checked || highlighted
	spacing: Theme.geometry.button.spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: contentItem.implicitHeight + root.topPadding + root.bottomPadding

	icon.color: root.color

	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font.size.s
	flat: true

	background: AsymmetricRoundedRectangle {
		id: backgroundRect

		roundedSide: AsymmetricRoundedRectangle.RoundedSide.All
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
