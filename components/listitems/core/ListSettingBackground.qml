/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	id: root

	required property color indicatorColor

	implicitWidth: Theme.geometry_listItem_width
	implicitHeight: Theme.geometry_listItem_height
	radius: Theme.geometry_listItem_radius

	Rectangle {
		visible: color.a > 0.0
		width: Theme.geometry_listItem_radius
		height: parent.height
		topLeftRadius: Theme.geometry_listItem_radius
		bottomLeftRadius: Theme.geometry_listItem_radius
		color: root.indicatorColor
	}
}
