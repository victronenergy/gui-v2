/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(var obj, var properties)
		signal pagePopRequested(var toPage)
		signal layerPushRequested(var obj, var properties)
		signal layerPopRequested()
	}

	// Ugly hack, but ...
	readonly property Page currentPage: controlsActive ? _controlCardsPage : _currentPage
	property Page _currentPage

	function setCurrentPage(page) {
		_currentPage = page
	}

	property bool controlsActive
	property QtObject _controlCardsPage

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
			&& root.currentPage !== null && root.currentPage !== undefined
			&& root.currentPage.fullScreenWhenIdle
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
}
