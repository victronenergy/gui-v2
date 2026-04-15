/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick

Flickable {
	id: root

	property real gradientBottomPadding

	flickableDirection: Qt.Horizontal
	boundsBehavior: Flickable.StopAtBounds
	clip: true

	// Show a gradient along the right edge.
	ViewGradient {
		parent: root
		x: root.width - width/2 - height/2
		y: width/2 - height/2
		width: root.height + root.gradientBottomPadding
		rotation: 270
		opacity: root.atXEnd ? 0 : 1

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.animation_page_fade_duration
			}
		}
	}

	// TODO add WheelHandler

}
