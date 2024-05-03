/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(var obj, var properties)
		signal pagePopRequested(var toPage)
		signal popAllPagesRequested()
	}

	property NavBar navBar
	property StatusBar statusBar

	property int interactivity: VenusOS.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: !Global.splashScreenVisible
			&& !!Global.mainView
			&& Global.mainView.currentPage !== null && Global.mainView.currentPage !== undefined
			&& Global.mainView.currentPage.fullScreenWhenIdle
			&& root.interactivity === VenusOS.PageManager_InteractionMode_Interactive
			&& BackendConnection.applicationVisible
		interval: Theme.animation_page_idleResize_timeout
		onTriggered: root.interactivity = VenusOS.PageManager_InteractionMode_EnterIdleMode
	}

	function pushPage(obj, properties) {
		emitter.pagePushRequested(obj, properties)
	}

	function popPage(toPage) {
		emitter.pagePopRequested(toPage)
	}

	function popAllPages() {
		emitter.popAllPagesRequested()
	}
	onWindowChanged: function (window) {
		keyEventFilter.window = window
	}

	KeyEventFilter {
		id: keyEventFilter
		consumeKeyEvents: root.interactivity === VenusOS.PageManager_InteractionMode_Idle
		onPressed: {
			if (idleModeTimer.running) {
				idleModeTimer.restart()
			}
			if (root.interactivity === VenusOS.PageManager_InteractionMode_Idle) {
				root.interactivity = VenusOS.PageManager_InteractionMode_EndFullScreen
			}
		}
	}
}
