/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	z: -1
	anchors.centerIn: parent
	color: Qt.rgba(0.0, 0.0, 0.0, 0.7)
	width: Screen.width / Global.scalingRatio
	height: Screen.height / Global.scalingRatio
}
