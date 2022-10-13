/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils
import "data" as Data
import "demo" as Demo

Item {
	id: root

	property alias mainView: mainView

	property var _inputComponent

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
			} else if (status === Loader.Error) {
				console.warn("Unable to load DemoManager:", errorString())
			}
		}
	}

	DemoModeDataPoint {
		forceValidDemoMode: !splashView.enabled
		onDemoModeChanged: _initializeDataSourceType()
		Component.onCompleted: _initializeDataSourceType()
		function _initializeDataSourceType() {
			if (demoMode === VenusOS.SystemSettings_DemoModeActive) {
				// Ensure Global.demoManager is set before initializing the DataManager.
				console.warn("Demo mode is active, setting mock data source")
				demoManagerLoader.active = true
				dataManager.dataSourceType = VenusOS.DataPoint_MockSource
			} else if (demoMode === VenusOS.SystemSettings_DemoModeInactive) {
				demoManagerLoader.active = false
				if (dbusConnected) {
					console.warn("Demo mode is inactive, setting DBus data source type")
					dataManager.dataSourceType = VenusOS.DataPoint_DBusSource
				} else {
					console.warn("Demo mode is inactive, setting MQTT data source type")
					dataManager.dataSourceType = VenusOS.DataPoint_MqttSource
				}
			}
		}
	}

	PageManager {
		id: pageManager
		Component.onCompleted: Global.pageManager = pageManager
	}

	MainView {
		id: mainView
		anchors.fill: parent
		pageManager: pageManager
	}

	SplashView {
		id: splashView
		anchors.fill: parent
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
	}

	// Create the InputPanel dynamically in case QtQuick.VirtualKeyboard is not available (e.g. on
	// Qt for WebAssembly due to QTBUG-104109).
	// Note the VKB layer is the top-most layer, to allow the idleModeMouseArea beneath to call
	// testCloseOnClick() when clicking outside of the focused text field, to auto-close the VKB.
	Component.onCompleted: {
		_inputComponent = Qt.createComponent(Qt.resolvedUrl("qrc:/components/InputPanel.qml"), Component.Asynchronous)
		_inputComponent.statusChanged.connect(function() {
			if (_inputComponent.status === Component.Ready) {
				Global.inputPanel = _inputComponent.createObject(root, { mainViewItem: mainView })
			} else if (_inputComponent.status === Component.Error) {
				console.warn("Cannot load InputPanel:", _inputComponent.errorString())
			}
		})
	}
}
