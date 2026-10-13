/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Button {
	id: root

	property color centerColor

	defaultBackgroundWidth: Theme.geometry_iochannel_control_height
	defaultBackgroundHeight: Theme.geometry_iochannel_control_height
	backgroundColor: "transparent"
	radius: Theme.geometry_size_6
	flat: false

	Rectangle {
		anchors {
			fill: parent
			leftMargin: (2 * Theme.geometry_size_2) + root.leftInset
			rightMargin: (2 * Theme.geometry_size_2) + root.rightInset
			topMargin: (2 * Theme.geometry_size_2) + root.topInset
			bottomMargin: (2 * Theme.geometry_size_2) + root.bottomInset
		}
		radius: root.radius - (2 * Theme.geometry_size_2)
		visible: root.centerColor.valid
		color: root.centerColor
	}
}
