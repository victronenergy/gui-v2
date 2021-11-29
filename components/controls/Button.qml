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

	property color color: Theme.primaryFontColor
	property color backgroundColor: flat ? 'transparent'
			: down ? Theme.okColor
			: Theme.okSecondaryColor
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius

	spacing: Theme.marginSmall
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth
	implicitHeight: contentItem.implicitHeight

	icon.color: root.color

	font.pixelSize: Theme.fontSizeMedium
	flat: true

	background: Rectangle {
		id: backgroundRect

		color: root.backgroundColor
		border.width: root.flat ? 0 : 2
		border.color: Theme.okColor
		radius: 6
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
