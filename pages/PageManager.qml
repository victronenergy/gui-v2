/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	required property Page currentMainPage
	required property PageStack pageStack

	property int interactivity: VenusOS.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: !Global.splashScreenVisible
			&& currentMainPage?.fullScreenWhenIdle
			&& root.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			&& BackendConnection.applicationVisible
		interval: Theme.animation_page_idleResize_timeout
		onTriggered: root.interactivity = VenusOS.PageManager_InteractionMode_EnterIdleMode
	}

	function pushPage(obj, properties, operation = PageStack.PushTransition) {
		pageStack.pushPage(obj, properties, operation)
	}

	function popPage(toPage, operation = PageStack.PopTransition) {
		pageStack.popPage(toPage, operation)
	}

	function popToAbovePage(page, operation = PageStack.PopTransition) {
		if (page) {
			const stackView = page.StackView.view
			for (let i = stackView.depth - 1; i >= 0; --i) {
				if (stackView.get(i, StackView.DontLoad) === page) {
					const targetPage = i === 0 ? null : stackView.get(i - 1, StackView.DontLoad)
					if (targetPage) {
						root.popPage(targetPage)
						return
					}
				}
			}
		}
		popAllPages(operation)
	}

	function popAllPages(operation = PageStack.PopTransition) {
		pageStack.popAllPages(operation)
	}

	function ensureInteractive() {
		if (idleModeTimer.running) {
			idleModeTimer.restart()
		}
		if (interactivity === VenusOS.PageManager_InteractionMode_Idle) {
			interactivity = VenusOS.PageManager_InteractionMode_EndFullScreen
			return true
		}
		return false
	}

	Component.onCompleted: Global.pageManager = root
}
