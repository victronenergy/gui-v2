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

	property int interactivity: PageManager.InteractionMode.Interactive

	property Timer _idleModeTimer: Timer {
		running: root.mainPageActive
			&& root.navBar
			&& root.navBar.currentUrl == "qrc:/pages/OverviewPage.qml"
			&& root.interactivity === PageManager.InteractionMode.Interactive
		interval: Theme.animation.overviewPage.interactive.timeout
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
