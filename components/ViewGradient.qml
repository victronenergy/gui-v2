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
	height: Theme.geometry.viewGradient.height
	gradient: Gradient {
		GradientStop {
			position: Theme.geometry.viewGradient.position1
			color: Theme.color.viewGradient.color1
		}
		GradientStop {
			position: Theme.geometry.viewGradient.position2
			color: Theme.color.viewGradient.color2
		}
		GradientStop {
			position: Theme.geometry.viewGradient.position3
			color: Theme.color.viewGradient.color3
		}
	}
}
