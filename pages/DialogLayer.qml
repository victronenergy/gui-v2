/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property QtObject currentDialog
	anchors.fill: parent

	function open(dialogComponent, properties) {
		let object
		if (typeof dialogComponent === "string") {
			const url = dialogComponent.indexOf("qrc:") === 0 ? dialogComponent : ".." + dialogComponent
			const component = Qt.createComponent(url)
			if (component.status !== Component.Ready) {
				console.warn("DialogLayer: failed to load dialog: " + dialogComponent + ": " + component.errorString())
				return null
			}
			object = component.createObject(root, properties || {})
		} else {
			object = dialogComponent.createObject(root, properties)
		}
		if (!object) {
			console.warn("DialogLayer: failed to create dialog object")
			return null
		}
		currentDialog = object
		currentDialog.closed.connect(function() {
			if (currentDialog) {
				currentDialog.destroy()
				currentDialog = null
			}
		})
		currentDialog.open()
		return currentDialog
	}

	Connections {
		target: Global.mainView
		ignoreUnknownSignals: true
		function onCurrentPageChanged() {
			// If the parent page is closed close the dialog also,
			// e.g. when an alarm is received, which pops existing
			// pages on the page stack and opens Notificationgs page.
			if (currentDialog) {
				currentDialog.destroy()
				currentDialog = null
			}
		}
	}

	Connections {
		target: ScreenBlanker
		function onBlankedChanged() {
			// If the screen blanker blanks the screen, we should
			// close the dialog.
			if (ScreenBlanker.blanked && currentDialog) {
				currentDialog.destroy()
				currentDialog = null
			}
		}
	}

	Connections {
		target: Theme
		function onScreenSizeChanged() {
			// If the orientation changes repeatedly between portrait and landscape, any open dialog
			// will not update its geometry correctly as expected. So, force-close any opened
			// dialogs when the screen size changes.
			if (currentDialog) {
				currentDialog.destroy()
				currentDialog = null
			}
		}
	}

	// For WebAssembly, if the firmware changed on device, this might
	// mean that the webassembly blob served by its webserver has changed.
	// We need to trigger a page reload to ensure we are running the right one.
	property Component _firmwareVersionRestartDialog: Component {
		ModalWarningDialog {
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_NoOptions
			//% "GX device has been updated"
			title: qsTrId("firmware_installed_build_gx_device_updated")
			//% "Page will automatically reload in ten seconds to load the latest version."
			description: qsTrId("firmware_installed_build_page_will_reload")
			icon.source: "qrc:/images/icon_info_48.svg"
			icon.color: Theme.color_blue
			Timer {
				running: true
				interval: 10*1000
				onTriggered: BackendConnection.reloadPage()
			}
		}
	}

	property bool _needPageReload: Global.needPageReload
	on_NeedPageReloadChanged: if (_needPageReload) open(_firmwareVersionRestartDialog)
}
