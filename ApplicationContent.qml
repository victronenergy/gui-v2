/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property alias mainView: mainView

	property var _inputComponent

	Keys.onPressed: function(event) {
		if (Global.mockDataSimulator) {
			Global.mockDataSimulator.keyPressed(event)
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
		Component.onCompleted: Global.mainView = mainView
	}

	FirmwareUpdate {
		id: firmwareUpdate
		Component.onCompleted: Global.firmwareUpdate = firmwareUpdate
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

	// We rely on the implicit Z ordering, so dialog/notification layers be declared after the other views.
	Item {
		id: dialogLayer

		anchors.fill: parent
		Component.onCompleted: Global.dialogLayer = dialogLayer
	}

	NotificationLayer {
		id: notificationLayer

		anchors.fill: parent
		Component.onCompleted: Global.notificationLayer = notificationLayer
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
