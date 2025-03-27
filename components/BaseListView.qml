/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListView {
	width: parent?.width ?? 0
	height: parent?.height ?? 0
	boundsBehavior: Flickable.StopAtBounds
	maximumFlickVelocity: Theme.geometry_flickable_maximumFlickVelocity
	flickDeceleration: Theme.geometry_flickable_flickDeceleration
}

