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
		EnterIdleMode,
		Idle,
		ExitIdleMode
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
	readonly property bool animatingIdleResize: _widgetResizingTimer.running
			|| PageManager.interactivity === PageManager.InteractionMode.EnterIdleMode
			|| PageManager.interactivity === PageManager.InteractionMode.ExitIdleMode

	property Timer idleModeTimer: Timer {
		running: root.mainPageActive
			&& root.navBar
			&& (root.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
				|| root.navBar.currentUrl == "qrc:/pages/LevelsPage.qml")
			&& root.interactivity === PageManager.InteractionMode.Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = PageManager.InteractionMode.EnterIdleMode
	}

	property Timer _widgetResizingTimer: Timer {
		interval: Theme.animation.page.idleResize.duration
		running: PageManager.interactivity === PageManager.InteractionMode.Idle
				 || PageManager.interactivity === PageManager.InteractionMode.Interactive
	}

	function pushPage(page) {
		pageToPush = page
		emitter.pagePushRequested()
	}

	function popPage() {
		emitter.pagePopRequested()
	}
}
