/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias mainView: mainView

	property var _inputComponent

	readonly property bool _goToNotifications: !!pageManager.navBar && !!Global.notifications
			&& Global.notifications.alarm
			&& !!pageManager.navBar.model && pageManager.navBar.model.count > 0 // if alarm is detected at startup, wait until nav bar is ready
	on_GoToNotificationsChanged: {
		if (_goToNotifications) {
			pageManager.popAllPages()
			mainView.controlsActive = false
			pageManager.navBar.setCurrentPage("NotificationsPage.qml")
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

	AllDevicesModel {
		id: allDevicesModel
		Component.onCompleted: Global.allDevicesModel = allDevicesModel
	}

	FirmwareUpdate {
		id: firmwareUpdate
		Component.onCompleted: Global.firmwareUpdate = firmwareUpdate
	}

	onWindowChanged: function (window) { screenBlanker.window = window }

	ScreenBlanker {
		id: screenBlanker
		enabled: !Global.splashScreenVisible && !(!!Global.notifications && Global.notifications.alert)
		displayOffTime: displayOffItem.isValid ? 1000*displayOffItem.value : 0.0
		property VeQuickItem displayOffItem: VeQuickItem {
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/DisplayOff" : ""
		}
		Component.onCompleted: Global.screenBlanker = screenBlanker
	}

	MouseArea {
		id: idleModeMouseArea
		anchors.fill: parent

		onPressed: function(mouse) {
			// block touch during navigation bar fadeout
			mouse.accepted = mainView.navBarAnimatingOut
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
	DialogLayer {
		id: dialogLayer

		anchors.fill: parent
		Component.onCompleted: Global.dialogLayer = dialogLayer
	}

	NotificationLayer {
		id: notificationLayer

		anchors.fill: parent
		Component.onCompleted: Global.notificationLayer = notificationLayer
	}

	// We only want the VKB on CerboGX/EkranoGX devices.
	// WebAssembly should use the native platform VKB.
	// Desktop platforms should use hardware keyboard.
	// Create the InputPanel dynamically in case QtQuick.VirtualKeyboard is not available (e.g. on
	// Qt for WebAssembly due to QTBUG-104109).
	// Note the VKB layer is the top-most layer, to allow the idleModeMouseArea beneath to call
	// testCloseOnClick() when clicking outside of the focused text field, to auto-close the VKB.
	Loader {
		id: loader

		asynchronous: true
		active: Global.isGxDevice
		source: "qrc:/qt/qml/Victron/VenusOS/components/InputPanel.qml"
		onLoaded: {
			item.mainViewItem = mainView
			Global.inputPanel = item
		}
	}
}
