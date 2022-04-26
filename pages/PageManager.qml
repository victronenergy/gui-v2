/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(var obj, var properties)
		signal pagePopRequested()
		signal layerPushRequested(var obj, var properties)
		signal layerPopRequested()
		signal allPagesLoaded()
	}

	// Ugly hack, but ...
	property var currentPage
	property bool sidePanelActive
	property var navBar
	property var statusBar
	property int levelsTabIndex

	property int interactivity: VenusOS.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: root.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| root.interactivity === VenusOS.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: root.currentPage !== null && root.currentPage !== undefined
			&& root.currentPage.fullScreenWhenIdle
			&& root.interactivity === VenusOS.PageManager_InteractionMode_Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = VenusOS.PageManager_InteractionMode_EnterIdleMode
	}

	function pushPage(obj, properties) {
		emitter.pagePushRequested(obj, properties)
	}

	function popPage() {
		emitter.pagePopRequested()
	}

	function pushLayer(obj, properties) {
		emitter.layerPushRequested(obj, properties)
	}

	function popLayer() {
		emitter.layerPopRequested()
	}
}
