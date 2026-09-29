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
	property Component _pendingShowComponent

	readonly property int _animationDuration: animationEnabled ? Theme.animation_controlCards_slide_duration : 1
	// Loader.Ready is only the empty page. ListView creates card delegates on a later polish,
	// so wait until those exist or the slide runs against a blank view and the cards pop in.
	readonly property bool _readyToShow: viewActive && status === Loader.Ready && _contentReady
	property bool _contentReady: false
	// True while this overlay is being compiled/instantiated, or while its list has not yet
	// created visible cards. MainView pauses Brief/Overview animations for the duration so
	// incubation is not starved on GX hardware.
	readonly property bool incubating: viewActive && status !== Loader.Error
			&& (status !== Loader.Ready || !_contentReady)
	// True after the in-slide has finished, until hide() is requested. False while incubating
	// or transitioning so MainView can keep the SwipeView visible until there is something
	// to fade to, instead of blanking the current page.
	readonly property bool shown: viewActive && !incubating && !animationRunning

	asynchronous: true
	active: viewActive
	// Retain the tree only after the first successful load. Assigning
	// active there removes the active: viewActive binding. hide() before
	// _contentReady (first open, or a later sourceComponent that is still
	// incubating) must deactivate so the Loader cannot keep incubating
	// after incubating is already false.
	on_ContentReadyChanged: {
		if (_contentReady && viewActive && active) {
			active = viewActive
		}
	}
	onViewActiveChanged: {
		if (!viewActive && !_contentReady) {
			active = false
		}
	}
	onActiveChanged: {
		if (!active) {
			_contentReady = false
		}
	}
	opacity: 0.0
	enabled: viewActive || outAnimation.running

	function show(viewComponent) {
		if (outAnimation.running) {
			// Changing sourceComponent would leave Loader.Ready and abort
			// outAnimation before SwipeView/NavBar opacity is restored.
			_pendingShowComponent = viewComponent
			return
		}
		_pendingShowComponent = null
		sourceComponent = viewComponent
		viewActive = true
		// Re-activate after Error or a canceled first load; the
		// active: viewActive binding is removed only once content is ready.
		if (!active) {
			active = true
		}
	}

	function hide() {
		_pendingShowComponent = null
		viewActive = false
	}

	onStatusChanged: {
		if (status === Loader.Error) {
			console.warn("Unable to load card view")
			// Loader.Error is terminal. Drop the failed activation so MainView
			// re-enables the SwipeView and page animations instead of treating
			// this as ongoing incubation.
			_pendingShowComponent = null
			viewActive = false
			active = false
			_contentReady = false
			return
		}
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

	// Stay incubating until in-view delegates exist. Do not treat a tick
	// budget as success: starting the slide while content is still missing
	// or Loading shows a blank overlay and the cards pop in afterward.
	Timer {
		interval: 16
		repeat: true
		running: root.viewActive && root.status === Loader.Ready && !root._contentReady
		property int _readyStreak: 0
		onRunningChanged: {
			if (running) {
				_readyStreak = 0
			}
		}
		onTriggered: {
			if (root._checkContentReady()) {
				_readyStreak++
				// Require two polishes so remaining in-view delegates can appear before the slide.
				if (_readyStreak >= 2) {
					root._contentReady = true
				}
			} else {
				_readyStreak = 0
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
		onFinished: {
			if (root._pendingShowComponent) {
				root.show(root._pendingShowComponent)
			}
		}

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
