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
		BeginEnterIdleMode, // opacity animation (fade out navbar)
		EnterIdleMode,      // y animation (slide out navbar)
		Idle,
		BeginExitIdleMode,  // y animation (slide in navbar)
		ExitIdleMode        // opacity animation (fade in navbar)
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

	// True when the UI layout on a page should be resizing, i.e. during the y animation phase of navbar.
	readonly property bool animatingIdleResize: PageManager.interactivity === PageManager.InteractionMode.EnterIdleMode
			|| PageManager.interactivity === PageManager.InteractionMode.BeginExitIdleMode

	property Timer _idleModeTimer: Timer {
		running: root.mainPageActive
			&& root.navBar
			&& (root.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
				|| root.navBar.currentUrl == "qrc:/pages/LevelsPage.qml")
			&& root.interactivity === PageManager.InteractionMode.Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = PageManager.InteractionMode.BeginEnterIdleMode
	}

	function pushPage(page) {
		pageToPush = page
		emitter.pagePushRequested()
	}

	function popPage() {
		emitter.pagePopRequested()
	}
}
