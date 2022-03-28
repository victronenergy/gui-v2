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

	property var pageToPush

	property QtObject emitter: QtObject {
		signal pagePushRequested()
		signal pagePopRequested()
	}

	// Ugly hack, but ...
	property bool sidePanelVisible
	property bool sidePanelActive
	property bool controlsVisible: true
	property bool mainPageActive: true
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
		running: root.mainPageActive
			&& root.navBar
			&& (root.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
				|| root.navBar.currentUrl == "qrc:/pages/LevelsPage.qml")
			&& root.interactivity === PageManager.InteractionMode.Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = PageManager.InteractionMode.EnterIdleMode
	}

	function pushPage(page) {
		pageToPush = page
		emitter.pagePushRequested()
	}

	function popPage() {
		emitter.pagePopRequested()
	}
}
