/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	anchors {
		bottom: root.bottom
		left: root.left
		right: root.right
	}
	height: Theme.geometry.viewGradient.height
	gradient: Global.viewGradient
}
