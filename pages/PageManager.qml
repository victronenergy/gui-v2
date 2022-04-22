/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	id: root

	enum InteractionMode {
		Interactive,
		EnterIdleMode,  // Fade out nav bar
		BeginFullScreen,    // Slide out nav bar, expand UI layout
		Idle,
		EndFullScreen,  // Slide in nav bar, compress UI layout
		ExitIdleMode    // Fade in nav bar
	}

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

	property int interactivity: PageManager.InteractionMode.Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: PageManager.interactivity === PageManager.InteractionMode.BeginFullScreen
			|| PageManager.interactivity === PageManager.InteractionMode.EndFullScreen

	readonly property bool expandLayout: PageManager.interactivity === PageManager.InteractionMode.BeginFullScreen
			|| PageManager.interactivity === PageManager.InteractionMode.Idle

	property Timer idleModeTimer: Timer {
		running: root.currentPage && root.currentPage.fullScreenWhenIdle
			&& root.interactivity === PageManager.InteractionMode.Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = PageManager.InteractionMode.EnterIdleMode
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
