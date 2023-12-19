/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as CT
import QtQuick.Controls as C
import Victron.VenusOS

CT.Button {
	id: root

	property color color: !enabled ? Theme.color.font.disabled
			: down ? Theme.color.button.down.text
			: Theme.color.font.primary
	property color backgroundColor: !enabled ? Theme.color.background.disabled
			: down ? downColor
			: flat ? "transparent"
			: Theme.color.darkOk
	property color downColor: flat ? "transparent"
			: Theme.color.ok
	property alias border: backgroundRect.border
	property alias radius: backgroundRect.radius

	down: pressed || checked
	spacing: Theme.geometry.button.spacing
	topPadding: 0
	bottomPadding: 0
	leftPadding: 0
	rightPadding: 0

	implicitWidth: contentItem.implicitWidth + root.leftPadding + root.rightPadding
	implicitHeight: contentItem.implicitHeight + root.topPadding + root.bottomPadding

	icon.color: root.color

	font.family: VenusFont.normal.name
	font.pixelSize: Theme.font.size.body1
	flat: true

	background: Rectangle {
		id: backgroundRect

		color: root.backgroundColor
		border.width: root.flat ? 0 : Theme.geometry.button.border.width
		border.color: Theme.color.ok
		radius: Theme.geometry.button.radius
	}

	contentItem: IconLabel {
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
