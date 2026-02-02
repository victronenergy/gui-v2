/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Window
import Victron.VenusOS

FocusScope {
	id: root

	property alias mainView: mainView

	property var _inputComponent

	MainView {
		id: mainView
		anchors.fill: parent
		focus: true
		Component.onCompleted: Global.mainView = mainView
	}

	FirmwareUpdate {
		id: firmwareUpdate
		Component.onCompleted: Global.firmwareUpdate = firmwareUpdate
	}

	QtObject {
		id: screenBlanker

		property VeQuickItem displayOffItem: VeQuickItem {
			uid: !!Global.systemSettings ? Global.systemSettings.serviceUid + "/Settings/Gui/DisplayOff" : ""
		}

		Component.onCompleted: {
			ScreenBlanker.enabled = Qt.binding(function() { return !Global.splashScreenVisible && !mainView.statusBar.notificationButtonVisible })
			ScreenBlanker.displayOffTime = Qt.binding(function() { return screenBlanker.displayOffItem.valid ? 1000*screenBlanker.displayOffItem.value : 0 })
			ScreenBlanker.window = root.Window.window
		}
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
			if (mainView.pageManager.ensureInteractive()) {
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
		animationEnabled: Global.animationEnabled
		Component.onCompleted: Global.notificationLayer = notificationLayer
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
	property Loader _vkbLoader: Loader {
		id: keyboardHandlerLoader

		parent: root.Overlay.overlay
		z: 1

		asynchronous: true
		active: Global.isGxDevice || BackendConnection.needsWasmKeyboardHandler

		// Note that for gx builds, all references to 'qrc:/.../Thing.qml' are intercepted by
		// UrlInterceptor and changed to '.../Thing.qml', i.e. they are loaded from the file
		// system, not from the compiled resources. This allows customers to edit qml source code
		// on the device without needing to build gui-v2 from source. This uses relative paths,
		// i.e. it doesn't matter where gui-v2 is installed, customers can change gui-v2 behavior
		// by editing qml.
		source: Global.isGxDevice
				? "qrc:/qt/qml/Victron/VenusOS/components/InputPanel.qml"
				: "qrc:/qt/qml/Victron/VenusOS/components/WasmVirtualKeyboardHandler.qml"

		property Rotation requiredRotation: Rotation {
			origin.x: width / 2
			origin.y: height / 2
			angle: 90
		}

		Component.onCompleted: {
			if (Global.main && Global.main.requiresRotation) {
				// See issue #2702.
				// Our workaround is the rotate the overlay layer so that it isn't
				// clipped by the render geometry, and then counter-rotate the
				// children (VKB, dialogs), and reposition children to account
				// for the coordinate system transformations.
				// We will remove all of this once we get EGLFS working and can
				// simply rotate the entire surface directly.
				root.Overlay.overlay.transform = keyboardHandlerLoader.requiredRotation
			}
		}
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
			|| (mainView.pageManager.interactivity !== VenusOS.PageManager_InteractionMode_Interactive
				&& mainView.pageManager.interactivity !== VenusOS.PageManager_InteractionMode_ExitIdleMode)
		window: root.Window.window

		onKeyPressed: {
			// When any key is pressed, bring the application out of inactive mode.
			Global.main.ensureApplicationActive()
			mainView.pageManager.ensureInteractive()
		}
	}
}
