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
		currentDialog = dialogComponent.createObject(root, properties)
		currentDialog.closed.connect(function() {
			if (currentDialog) {
				currentDialog.destroy()
				currentDialog = null
			}
		})
		currentDialog.open()
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
		function onScreenIsBlankedChanged() {
			// If the screen blanker blanks the screen, we should
			// close the dialog.
			if (Global.mainView.screenIsBlanked && currentDialog) {
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
			//% "Firmware version update detected"
			title: qsTrId("firmware_installed_build_version_update_detected")
			//% "Page will automatically reload in ten seconds to load the latest version."
			description: qsTrId("firmware_installed_build_page_will_reload")
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
