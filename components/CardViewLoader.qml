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
	required property bool animationEnabled
	property color backgroundColor: Theme.color_page_background
	property color statusBarBackgroundColor: backgroundColor
	readonly property bool animationRunning: inAnimation.running || outAnimation.running
	readonly property Flickable flickableView: item?.flickableView ?? null
	property bool viewActive: false

	readonly property int _animationDuration: animationEnabled ? Theme.animation_controlCards_slide_duration : 1
	// Loader.Ready is only the empty page. ListView creates card delegates on a later polish,
	// so wait until those exist or the slide runs against a blank view and the cards pop in.
	readonly property bool _readyToShow: viewActive && status === Loader.Ready && _contentReady
	property bool _contentReady: false
	// True while this overlay is being compiled/instantiated, or while its list has not yet
	// created visible cards. MainView pauses Brief/Overview animations for the duration so
	// incubation is not starved on GX hardware.
	readonly property bool incubating: viewActive && (status !== Loader.Ready || !_contentReady)

	asynchronous: true
	active: viewActive
	onActiveChanged: if (active) active = viewActive // remove binding
	opacity: 0.0
	enabled: viewActive || outAnimation.running

	onStatusChanged: {
		if (status !== Loader.Ready) {
			_contentReady = false
		}
	}

	function _checkContentReady() {
		const view = flickableView
		if (!view) {
			return true
		}
		view.forceLayout()
		if (view.header && !view.headerItem) {
			return false
		}
		const header = view.headerItem
		if (header && header.status === Loader.Loading) {
			return false
		}
		if (view.count === 0) {
			return true
		}
		let created = 0
		for (let i = 0; i < view.count; ++i) {
			const delegate = view.itemAtIndex(i)
			if (!delegate) {
				continue
			}
			created++
			if (delegate.status === Loader.Loading) {
				return false
			}
		}
		return created > 0
	}

	Timer {
		interval: 16
		repeat: true
		running: root.viewActive && root.status === Loader.Ready && !root._contentReady
		property int _attempts: 0
		property int _readyStreak: 0
		onRunningChanged: {
			if (running) {
				_attempts = 0
				_readyStreak = 0
			}
		}
		onTriggered: {
			_attempts++
			if (root._checkContentReady()) {
				_readyStreak++
				// Require two polishes so remaining in-view delegates can appear before the slide.
				if (_readyStreak >= 2 || _attempts >= 60) {
					root._contentReady = true
				}
			} else {
				_readyStreak = 0
				if (_attempts >= 60) {
					root._contentReady = true
				}
			}
		}
	}

	SequentialAnimation {
		id: inAnimation
		running: root._readyToShow

		ParallelAnimation {
			YAnimator {
				target: root
				from: root.statusBarItem.height - Theme.geometry_controlCards_slide_distance
				to: root.statusBarItem.height
				duration: root._animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root
				from: 0.0
				to: 1.0
				duration: root._animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.swipeViewItem
				from: 1.0
				to: 0.0
				duration: root._animationDuration
				easing.type: Easing.OutSine
			}
			OpacityAnimator {
				target: root.navBarItem
				from: 1.0
				to: 0.0
				duration: root._animationDuration
				easing.type: Easing.OutSine
			}
			ColorAnimation {
				target: root
				property: "statusBarBackgroundColor"
				from: root.backgroundColor
				to: Theme.color_page_background
				duration: root._animationDuration
				easing.type: Easing.OutSine
			}
		}
	}

	SequentialAnimation {
		id: outAnimation
		running: root.active && !root.viewActive && root.status === Loader.Ready && root._contentReady

		ParallelAnimation {
			YAnimator {
				target: root
				from: root.statusBarItem.height
				to: root.statusBarItem.height - Theme.geometry_controlCards_slide_distance
				duration: root._animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root
				from: 1.0
				to: 0.0
				duration: root._animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.swipeViewItem
				from: 0.0
				to: 1.0
				duration: root._animationDuration
				easing.type: Easing.InSine
			}
			OpacityAnimator {
				target: root.navBarItem
				from: 0.0
				to: 1.0
				duration: root._animationDuration
				easing.type: Easing.InSine
			}
			ColorAnimation {
				target: root
				property: "statusBarBackgroundColor"
				from: Theme.color_page_background
				to: root.backgroundColor
				duration: root._animationDuration
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
