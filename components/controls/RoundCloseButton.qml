/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

PressArea {
	width: Theme.geometry_roundCloseButton_size
	height: Theme.geometry_roundCloseButton_size
	radius: Theme.geometry_roundCloseButton_radius

	Rectangle {
		anchors.fill: parent
		radius: Theme.geometry_roundCloseButton_radius
		color: Theme.color_roundCloseButton_background
	}

	CP.ColorImage {
		anchors.centerIn: parent
		// width: Theme.geometry_roundCloseButton_iconSize
		// height: Theme.geometry_roundCloseButton_iconSize

		color: Theme.color_roundCloseButton_foreground
		source: "qrc:/images/icon_close_small.svg"
	}
}
