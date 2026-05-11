/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// A rectangle with a rounded bottom-right corner, with an ability to animate its color in a
// progressive fashion.

Rectangle {
	id: root

	property alias secondaryColor: animatedRect.color
	property alias animating: slidingAnimation.running

	signal animationFinished()

	color: Theme.color_dimGreen
	topLeftRadius: 0
	topRightRadius: 0
	bottomLeftRadius: 0
	bottomRightRadius: Theme.geometry_button_radius

	// Slowly expands a rectangle from the left edge to the right.
	SequentialAnimation {
		id: slidingAnimation

		NumberAnimation {
			target: animatedRect
			property: "width"
			from: 1
			to: root.width
			duration: Theme.animation_acceptButtonBackground_expand_duration
		}

		ScriptAction {
			script: {
				root.animationFinished()
			}
		}
	}

	Rectangle {
		id: animatedRect

		width: 0
		height: parent.height
		visible: slidingAnimation.running
	}
}
