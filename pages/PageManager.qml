/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(obj: var, properties: var, operation: int)
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

	function popAllPages(operation = PageStack.PopTransition) {
		emitter.popAllPagesRequested(operation)
	}
}
