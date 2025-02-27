/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Loader {
	id: root

	required property Item statusBarItem
	required property Item navBarItem
	required property Item swipeViewItem
	property color backgroundColor: Theme.color_page_background
	readonly property bool animationRunning: inAnimation.running || outAnimation.running
	property int animationDuration: Theme.animation_controlCards_slide_duration
	property bool viewActive: false

	active: viewActive
	onActiveChanged: if (active) active = viewActive // remove binding
	opacity: 0.0
	enabled: viewActive || outAnimation.running

	SequentialAnimation {
		id: inAnimation
		running: root.viewActive

		ParallelAnimation {
			YAnimator {
				target: root
				from: root.statusBarItem.height - Theme.geometry_controlCards_slide_distance
				to: root.statusBarItem.height
				duration: root.animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root
				from: 0.0
				to: 1.0
				duration: root.animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.swipeViewItem
				from: 1.0
				to: 0.0
				duration: root.animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.navBarItem
				from: 1.0
				to: 0.0
				duration: root.animationDuration
				easing.type: Easing.OutSine
			}
			ColorAnimation {
				target: statusBarItem
				property: "backgroundColor"
				from: root.backgroundColor
				to: Theme.color_page_background
				duration: root.animationDuration
				easing.type: Easing.OutSine
			}
		}
	}

	SequentialAnimation {
		id: outAnimation
		running: root.active && !root.viewActive

		ParallelAnimation {
			YAnimator {
				target: root
				from: root.statusBarItem.height
				to: root.statusBarItem.height - Theme.geometry_controlCards_slide_distance
				duration: root.animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root
				from: 1.0
				to: 0.0
				duration: root.animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.swipeViewItem
				from: 0.0
				to: 1.0
				duration: root.animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.navBarItem
				from: 0.0
				to: 1.0
				duration: root.animationDuration
				easing.type: Easing.InSine
			}
			ColorAnimation {
				target: root.statusBarItem
				property: "backgroundColor"
				from: Theme.color_page_background
				to: root.backgroundColor
				duration: root.animationDuration
				easing.type: Easing.InSine
			}
			PropertyAction {
				target: root.statusBarItem
				property: "focus"
				value: true
			}
		}
	}
}
