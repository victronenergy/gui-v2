/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	anchors.fill: parent

	function open(dialogComponent, properties) {
		const dialog = dialogComponent.createObject(root, properties)
		dialog.closed.connect(function() {
			dialog.destroy()
		})
		dialog.open()
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
				onTriggered: Qt.quit() // the aboutToQuit handler will trigger page reload.
			}
		}
	}

	property bool _needPageReload: Qt.platform.os == "wasm" && Global.firmwareInstalledBuildUpdated
	on_NeedPageReloadChanged: if (_needPageReload) open(_firmwareVersionRestartDialog)
}
