/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data" as Data
import "demo" as Demo

Window {
	id: root

	property alias dialogManager: dialogManager

	width: [800, 1024][Theme.screenSize]
	height: [480, 600][Theme.screenSize]
	color: mainView.backgroundColor

	//: Application title
	//% "Venus OS GUI"
	//~ Context only shown on desktop systems
	title: qsTrId("venus_os_gui")

	Data.DataManager {
		id: dataManager
	}

	Loader {
		id: demoManagerLoader

		active: false
		sourceComponent: Demo.DemoManager {}
		onStatusChanged: {
			if (status === Loader.Ready) {
				if (Global.demoManager != null) {
					console.warn("Global.demoManager is already set, overwriting")
				}
				Global.demoManager = item
			} else if (status === Loader.Ready) {
				console.warn("Unable to load DemoManager:", errorString())
			}
		}
	}

	DemoModeDataPoint {
		forceValidDemoMode: !splashView.enabled
		onDemoModeChanged: {
			if (demoMode === VenusOS.SystemSettings_DemoModeActive) {
				// Ensure Global.demoManager is set before initializing the DataManager.
				demoManagerLoader.active = true
				dataManager.dataSourceType = VenusOS.DataPoint_MockSource
			} else if (demoMode === VenusOS.SystemSettings_DemoModeInactive) {
				demoManagerLoader.active = false
				dataManager.dataSourceType = VenusOS.DataPoint_DBusSource
			}
		}
	}

	PageManager {
		id: pageManager

		Component.onCompleted: Global.pageManager = pageManager
	}

	SplashView {
		id: splashView
		anchors.fill: parent
		enabled: true
		opacity: enabled ? 1 : 0

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.animation.page.fade.duration
				easing.type: Easing.InOutQuad
			}
		}

		onHideSplash: {
			splashView.enabled = false
			mainView.enabled = true
		}
	}

	MainView {
		id: mainView
		anchors.fill: parent
		enabled: false
		opacity: enabled ? 1 : 0
		pageManager: pageManager

		Behavior on opacity {
			NumberAnimation {
				duration: Theme.animation.page.fade.duration
				easing.type: Easing.InOutQuad
			}
		}
	}

	MouseArea {
		id: idleModeMouseArea

		anchors.fill: parent
		enabled: pageManager.interactivity === VenusOS.PageManager_InteractionMode_Idle
		onClicked: pageManager.interactivity = VenusOS.PageManager_InteractionMode_EndFullScreen
	}

	MouseArea {
		anchors.fill: parent
		onPressed: function(mouse) {
			mouse.accepted = false
			if (pageManager.idleModeTimer.running) {
				pageManager.idleModeTimer.restart()
			}
		}
	}

	DialogManager {
		id: dialogManager
	}
}
