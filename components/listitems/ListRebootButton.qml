/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import QtQuick.Templates as T

ListButton {
	id: root

	text: CommonWords.reboot
	//% "Reboot now"
	secondaryText: qsTrId("reboot_button_reboot_now")
	writeAccessLevel: VenusOS.User_AccessType_User
	onClicked: Global.dialogLayer.open(confirmRebootDialogComponent)

	Component {
		id: confirmRebootDialogComponent

		ModalWarningDialog {
			//% "Press 'OK' to reboot"
			title: qsTrId("reboot_button_press_ok_to_reboot")
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
			onClosed: {
				if (result === T.Dialog.Accepted) {
					Global.venusPlatform.reboot()
					Qt.callLater(Global.dialogLayer.open, rebootingDialogComponent)
				}
			}
		}
	}

	Component {
		id: rebootingDialogComponent

		ModalWarningDialog {
			title: BackendConnection.type === BackendConnection.DBusSource
				//% "Rebooting..."
				? qsTrId("reboot_button_dialoglayer_rebooting")
				//% "Device has been rebooted."
				: qsTrId("reboot_button_dialoglayer_rebooted")

			// On device, dialog cannot be dismissed; just wait until device is rebooted.
			dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
			footer.enabled: BackendConnection.type !== BackendConnection.DBusSource
			footer.opacity: footer.enabled ? 1 : 0
		}
	}
}
