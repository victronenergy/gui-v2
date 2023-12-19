/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Templates as T
import Victron.VenusOS

Rectangle {
	property alias title: title
	property alias status: status

	width: Theme.geometry.controlCard.maximumWidth
	height: parent ? parent.height : 0
	color: Theme.color.background.secondary
	radius: Theme.geometry.panel.radius

	IconLabel {
		id: title
		anchors {
			top: parent.top
			topMargin: Theme.geometry.controlCard.title.topMargin
			left: parent.left
			leftMargin: Theme.geometry.controlCard.contentMargins
		}
		spacing: Theme.geometry.controlCard.title.spacing
		display: T.AbstractButton.TextBesideIcon
		icon.color: Theme.color.font.primary

		font.family: VenusFont.normal.name
		font.pixelSize: Theme.font.size.body1
		color: Theme.color.font.primary
	}

	Label {
		id: status

		anchors {
			top: title.bottom
			left: title.left
		}
		font.pixelSize: Theme.font.size.body3
	}
}
