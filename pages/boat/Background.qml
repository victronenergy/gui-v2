/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Item {
	id: root

	required property MotorDrives motorDrives

	component Shadow : CP.ColorImage {
		width: Theme.geometry_boatPage_shadow_width
		height: Theme.geometry_boatPage_shadow_height
		source: "qrc:/images/boat_glow.png"
		color: motorDrives.isRegenerating ? Theme.color_boatPage_regenProgress : undefined
	}

	Shadow {
		id: shadowTopLeft

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_shadow_topRow_topMargin
			left: parent.left
			leftMargin: Theme.geometry_boatPage_shadow_horizontalMargin
		}

		rotation: 180
	}

	Shadow {
		id: shadowBottomLeft

		anchors {
			top: parent.top
			topMargin: Theme.geometry_boatPage_shadow_bottomRow_topMargin
			left: shadowTopLeft.left
		}
		mirror: true
	}

	Shadow {
		id: shadowTopRight
		anchors {
			top: shadowTopLeft.top
			right: parent.right
			rightMargin: Theme.geometry_boatPage_shadow_horizontalMargin
		}
		mirror: true
		rotation: 180
	}

	Shadow {
		id: shadowBottomRight
		anchors {
			bottom: shadowBottomLeft.bottom
			right: shadowTopRight.right
		}
	}
}
