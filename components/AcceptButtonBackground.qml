/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

// A rectangle with a rounded bottom-right corner, with an ability to animate its color in a
// progressive fashion.

Item {
	id: root

	property color color: Theme.color_dimGreen
	property alias secondaryColor: animatedRect.color
	property alias animating: slidingAnimation.running

	signal animationFinished

	width: parent.width
	height: parent.height

	// Slowly expands a rectangle from the left edge to the right. It doesn't quite stretch to the
	// right edge as the rounded bit makes it tricky, but it's close enough.
	SequentialAnimation {
		id: slidingAnimation

		NumberAnimation {
			target: animatedRect
			property: "width"
			from: 1
			to: leftRect.width
			duration: Theme.animation_acceptButtonBackground_expand_duration
		}

		ScriptAction {
			script: {
				root.animationFinished();
			}
		}
	}

	// Left rectangle, stretches almost to right edge
	Rectangle {
		id: leftRect

		anchors {
			top: parent.top
			bottom: parent.bottom
			left: parent.left
			right: parent.right
			rightMargin: Theme.geometry_button_radius
		}
		color: root.color

		Rectangle {
			id: animatedRect

			width: 0
			height: parent.height
			visible: slidingAnimation.running
		}
	}

	// Right rectangle, fills in space above the rounded rect
	Rectangle {
		id: rightRect

		anchors {
			top: parent.top
			bottom: parent.bottom
			bottomMargin: Theme.geometry_button_radius
			left: leftRect.right
			right: parent.right
		}
		color: root.color
	}

	// Clipped rounded rect at right-bottom
	Item {
		anchors {
			bottom: parent.bottom
			right: parent.right
		}
		width: Theme.geometry_button_radius
		height: Theme.geometry_button_radius
		clip: true

		Rectangle {
			anchors {
				bottom: parent.bottom
				right: parent.right
			}
			width: 2 * parent.width
			height: 2 * parent.width
			radius: Theme.geometry_button_radius
			color: root.color
		}
	}
}
