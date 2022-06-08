/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data" as Data
import "demo" as Demo

Item {
	property alias dialogManager: dialogManager
	property alias mainView: mainView

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

		onPressed: function(mouse) {
			mouse.accepted = false
			if (pageManager.idleModeTimer.running) {
				pageManager.idleModeTimer.restart()
			}
			if (pageManager.interactivity === VenusOS.PageManager_InteractionMode_Idle) {
				mouse.accepted = true
				pageManager.interactivity = VenusOS.PageManager_InteractionMode_EndFullScreen
			}
			if (Global.inputPanel && Global.inputPanel.testCloseOnClick(idleModeMouseArea, mouse.x, mouse.y)) {
				mouse.accepted = true
			}
		}
	}

	DialogManager {
		// we rely on the implicit Z ordering, so must be declared after the other views.
		id: dialogManager
	}

	// Load the VKB separately so that the app still runs if QtQuick.VirtualKeyboard is not
	// available (e.g. in Qt WASM).
	// Place this above idleModeMouseArea so that the mouse area can call testCloseOnClick() when
	// clicking outside of the focused text field, below the VKB layer.
	Loader {
		id: inputPanelLoader

		x: 0
		y: root.height
		source: "qrc:/components/InputPanel.qml"

		onStatusChanged: {
			if (status === Loader.Ready) {
				Global.inputPanel = item
			} else if (status === Loader.Error) {
				console.warn("Cannot load InputPanel!")
			}
		}

		states: State {
			name: "visible"
			when: Qt.inputMethod.visible

			PropertyChanges {
				target: inputPanelLoader
				y: root.height - inputPanelLoader.item.height
			}
		}

		transitions: Transition {
			NumberAnimation {
				property: "y"
				duration: Theme.animation.inputPanel.slide.duration
				easing.type: Easing.InOutQuad
			}
		}

	}
}
