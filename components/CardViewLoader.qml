/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	property color backgroundColor: Theme.color_page_background
	required property Item animationRefStatusBar
	required property Item anamationRefNavBar
	required property Item animationRefMainbody
	readonly property bool animationRunning: inAnimation.running || outAnimation.running
	property int animationDuration: Theme.animation_controlCards_slide_duration
	property bool viewActive: false

	active: viewActive
	onActiveChanged: if (active) active = viewActive // remove binding
	z: 1
	opacity: 0.0
	enabled: viewActive || outAnimation.running

	SequentialAnimation {
		id: inAnimation
		running: viewActive

		ParallelAnimation {
			YAnimator {
				target: root
				from: animationRefStatusBar.height - Theme.geometry_controlCards_slide_distance
				to: animationRefStatusBar.height
				duration: animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root
				from: 0.0
				to: 1.0
				duration: animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.animationRefMainbody
				from: 1.0
				to: 0.0
				duration: animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.anamationRefNavBar
				from: 1.0
				to: 0.0
				duration: animationDuration
				easing.type: Easing.OutSine
			}
			ColorAnimation {
				target: animationRefStatusBar
				property: "backgroundColor"
				from: root.backgroundColor
				to: Theme.color_page_background
				duration: animationDuration
				easing.type: Easing.OutSine
			}
		}
	}

	SequentialAnimation {
		id: outAnimation
		running: root.active && !viewActive

		ParallelAnimation {
			YAnimator {
				target: root
				from: animationRefStatusBar.height
				to: animationRefStatusBar.height - Theme.geometry_controlCards_slide_distance
				duration: animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root
				from: 1.0
				to: 0.0
				duration: animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.animationRefMainbody
				from: 0.0
				to: 1.0
				duration: animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.anamationRefNavBar
				from: 0.0
				to: 1.0
				duration: animationDuration
				easing.type: Easing.InSine
			}
			ColorAnimation {
				target: root.animationRefStatusBar
				property: "backgroundColor"
				from: Theme.color_page_background
				to: root.backgroundColor
				duration: animationDuration
				easing.type: Easing.InSine
			}
		}
	}
}

