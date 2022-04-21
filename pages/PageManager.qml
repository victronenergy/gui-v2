/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	property QtObject emitter: QtObject {
		signal pagePushRequested(var obj, var properties)
		signal pagePopRequested()
		signal layerPushRequested(var obj, var properties)
		signal layerPopRequested()

		signal demoKeyPressed(var event)
	}

	// Ugly hack, but ...
	property var currentPage
	property bool sidePanelActive
	property var navBar
	property var statusBar
	property int levelsTabIndex

	property int interactivity: VenusOS.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: PageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| PageManager.interactivity === VenusOS.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: PageManager.interactivity === VenusOS.PageManager_InteractionMode_BeginFullScreen
			|| PageManager.interactivity === VenusOS.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: root.currentPage && root.currentPage.fullScreenWhenIdle
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
