/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls as QtQuickControls
import Victron.VenusOS

FocusScope {
	id: root

	property alias mainView: mainView

	property var _inputComponent

	PageManager {
		id: pageManager
		Component.onCompleted: Global.pageManager = pageManager
	}

	MainView {
		id: mainView
		anchors.fill: parent
		pageManager: pageManager
		focus: true
		Component.onCompleted: Global.mainView = mainView
	}

	FirmwareUpdate {
		id: firmwareUpdate
		Component.onCompleted: Global.firmwareUpdate = firmwareUpdate
	}

	ScreenBlanker {
		id: screenBlanker
		enabled: !Global.splashScreenVisible && !(!!Global.pageManager && Global.pageManager.statusBar.notificationButtonVisible)
		displayOffTime: displayOffItem.valid ? 1000*displayOffItem.value : 0.0
		window: root.Window.window
		property VeQuickItem displayOffItem: VeQuickItem {
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/DisplayOff" : ""
		}
		Component.onCompleted: Global.screenBlanker = screenBlanker
	}

	MouseArea {
		id: idleModeMouseArea

		VeQuickItem {
			id: touchEnabled

			property bool _initialized: false

			uid: BackendConnection.serviceUidForType("settings") + "/Settings/Gui/TouchEnabled"
			onValueChanged: {
				if (_initialized) { // Only show the notification when the value changes, not when the application is loaded
					Global.showToastNotification(VenusOS.Notification_Info,
												 (value ?
													 //% "Touch input on"
													 qsTrId("application_content_touch_input_on") :
													 //% "Touch input off"
													 qsTrId("application_content_touch_input_off")),
												 3000)
				}
				_initialized = true
			}
		}

		anchors.fill: parent

		onPressed: function(mouse) {
			Global.main.ensureApplicationActive()

			if (Global.isGxDevice && !touchEnabled.value) {
				//% "Touch input disabled"
				Global.showToastNotification(VenusOS.Notification_Info, qsTrId("application_content_touch_input_disabled"), 1000)
				mouse.accepted = true
				return
			}

			// block touch during navigation bar fadeout
			mouse.accepted = mainView.navBarAnimatingOut

			// Exit idle mode if needed, and consume the event so that this does not trigger a press
			// event on the page in the process of exiting idle mode.
			if (pageManager.ensureInteractive()) {
				mouse.accepted = true
			}

			// Consume the event if the press event closes the VKB.
			if (keyboardHandlerLoader.item && keyboardHandlerLoader.item.acceptMouseEvent(idleModeMouseArea, mouse.x, mouse.y)) {
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

		// technically, the notification layer is not related to the notifications page
		// but we need to way to expose the "go to notifications page" functionality
		// and the notifications layer is already part of the global object.
		function popAndGoToNotifications() {
			pageManager.popAllPages()
			mainView.cardsActive = false
			pageManager.navBar.setCurrentPage("NotificationsPage.qml")
		}
	}

	// Keyboard handling:
	// - On CerboGX/EkranoGX devices, show the Qt VKB using components/InputPanel.qml.
	// - On Wasm mobile, the mobile OS shows the native VKB. If in landscape orientation, use
	//   components/WasmVirtualKeyboardHandler.qml to auto-scroll flickables and ensure the active
	//   text field is not obscured by the native VKB.
	// - On Wasm desktop and desktop platforms, no special input handling is required, as the
	//   hardware keyboard can be used for text input.
	//
	// Note this Loader is the top-most layer, to allow the idleModeMouseArea beneath to call
	// acceptMouseEvent() when clicking outside of the focused text field, to auto-close the Qt VKB.
	Loader {
		id: keyboardHandlerLoader

		asynchronous: true
		active: Global.isGxDevice
			|| (BackendConnection.needsWasmKeyboardHandler && Global.main.width > Global.main.height)
		source: Global.isGxDevice
				? "qrc:/qt/qml/Victron/VenusOS/components/InputPanel.qml"
				: "qrc:/qt/qml/Victron/VenusOS/components/WasmVirtualKeyboardHandler.qml"
		parent: QtQuickControls.Overlay.overlay
		z: 1
	}

	// Sometimes, the wasm code may crash. Use a watchdog to detect this and reload the page when necessary.
	Timer {
		running: Qt.platform.os === "wasm" && Global.backendReadyLatched
		repeat: true
		interval: 1000
		onTriggered: BackendConnection.hitWatchdog()
	}

	KeyEventFilter {
		// When the UI is inactive, consume key events so that they are not processed by the UI.
		consumeKeyEvents: !Global.applicationActive
			|| (pageManager.interactivity !== VenusOS.PageManager_InteractionMode_Interactive
				&& pageManager.interactivity !== VenusOS.PageManager_InteractionMode_ExitIdleMode)
		window: root.Window.window

		onKeyPressed: {
			// When any key is pressed, bring the application out of inactive mode.
			Global.main.ensureApplicationActive()
			pageManager.ensureInteractive()
		}
	}
}
