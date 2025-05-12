/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import QtQuick.Controls as C
import Victron.VenusOS

QtObject {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(obj: var, properties: var, operation: int)

		// NB. 'toPage' has to be a 'var', not a 'Page', otherwise 'emitter.pagePopRequested(undefined, operation)' becomes 'emitter.pagePopRequested(null, operation)',
		// which pops all the way to the bottom of the stack, instead of just a single page.
		signal pagePopRequested(toPage: var, operation: int)
		signal popAllPagesRequested(operation: int)
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

	function pushPage(obj, properties, operation = PageStack.PushTransition) {
		emitter.pagePushRequested(obj, properties, operation)
	}

	function popPage(toPage, operation = PageStack.PopTransition) {
		emitter.pagePopRequested(toPage, operation)
	}

	function popToAbovePage(page, operation = PageStack.PopTransition) {
		if (page) {
			const stackView = page.C.StackView.view
			for (let i = stackView.depth - 1; i >= 0; --i) {
				if (stackView.get(i, C.StackView.DontLoad) === page) {
					const targetPage = i === 0 ? null : stackView.get(i - 1, C.StackView.DontLoad)
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
		emitter.popAllPagesRequested(operation)
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
}
