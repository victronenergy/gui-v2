/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Rectangle {
	anchors {
		bottom: root.bottom
		left: root.left
		right: root.right
	}
	height: Theme.geometry_viewGradient_height
	gradient: Gradient {
		GradientStop {
			position: Theme.geometry_viewGradient_position1
			color: Theme.color_viewGradient_color1
		}
		GradientStop {
			position: Theme.geometry_viewGradient_position2
			color: Theme.color_viewGradient_color2
		}
		GradientStop {
			position: Theme.geometry_viewGradient_position3
			color: Theme.color_viewGradient_color3
		}
	}
}
