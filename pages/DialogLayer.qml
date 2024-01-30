/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Templates as T

Item {
	id: root

	property ModalWarningDialog _rebootDialog

	function showRebootDialog() {
		if (!_rebootDialog) {
			_rebootDialog = rebootDialogComponent.createObject(root)
		}
		_rebootDialog.open()
	}

	anchors.fill: parent

	Component {
		id: rebootDialogComponent

		ModalWarningDialog {
			title: BackendConnection.type === BackendConnection.DBusSource
				//% "Rebooting..."
				? qsTrId("dialoglayer_rebooting")
				//% "Device has been rebooted."
				: qsTrId("dialoglayer_rebooted")

			// On device, dialog cannot be dismissed; just wait until device is rebooted.
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
			footer.enabled: BackendConnection.type !== BackendConnection.DBusSource
			footer.opacity: footer.enabled ? 1 : 0
			closePolicy: T.Popup.NoAutoClose
		}
	}
}
