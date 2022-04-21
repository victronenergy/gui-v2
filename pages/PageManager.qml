/*
** Copyright (C) 2021 Victron Energy B.V.
*/
pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	id: root

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

	property int interactivity: Enums.PageManager_InteractionMode_Interactive

	// True when the UI layout on a page should be resizing before/after idle/interactive mode changes.
	readonly property bool animatingIdleResize: PageManager.interactivity === Enums.PageManager_InteractionMode_BeginFullScreen
			|| PageManager.interactivity === Enums.PageManager_InteractionMode_EndFullScreen

	readonly property bool expandLayout: PageManager.interactivity === Enums.PageManager_InteractionMode_BeginFullScreen
			|| PageManager.interactivity === Enums.PageManager_InteractionMode_Idle

	property Timer idleModeTimer: Timer {
		running: root.mainPageActive
			&& root.navBar
			&& (root.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
				|| root.navBar.currentUrl == "qrc:/pages/LevelsPage.qml")
			&& root.interactivity === Enums.PageManager_InteractionMode_Interactive
		interval: Theme.animation.page.idleResize.timeout
		onTriggered: root.interactivity = Enums.PageManager_InteractionMode_EnterIdleMode
	}

	function pushPage(page) {
		pageToPush = page
		emitter.pagePushRequested()
	}

	function popPage() {
		emitter.pagePopRequested()
	}
}
