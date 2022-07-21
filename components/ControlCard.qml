/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import QtQuick.Controls as C
import Victron.VenusOS

Rectangle {
	property alias title: title
	property alias status: status

	width: Theme.geometry.controlCard.maximumWidth
	height: parent ? parent.height : 0
	color: Theme.color.background.secondary
	radius: Theme.geometry.panel.radius

	CP.IconLabel {
		id: title
		anchors {
			top: parent.top
			topMargin: Theme.geometry.controlCard.title.topMargin
			left: parent.left
			leftMargin: Theme.geometry.controlCard.title.leftMargin
		}

		leftPadding: Theme.geometry.controlCard.title.leftPadding
		spacing: Theme.geometry.controlCard.title.spacing
		display: C.AbstractButton.TextBesideIcon
		icon.height: Theme.geometry.controlCard.title.icon.height
		icon.color: Theme.color.font.primary

		font.family: VenusFont.normal.name
		font.pixelSize: Theme.font.size.s
		color: Theme.color.font.primary
	}

	Label {
		id: status

		anchors {
			top: title.bottom
			left: parent.left
			leftMargin: Theme.geometry.controlCard.title.leftMargin
		}
		font.pixelSize: Theme.font.size.l
	}
}
