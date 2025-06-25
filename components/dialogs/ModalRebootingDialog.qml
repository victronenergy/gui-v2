/*
** Copyright (C) 2025 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalWarningDialog {
	id: root

	title: BackendConnection.type === BackendConnection.DBusSource
		//% "Rebooting..."
		? qsTrId("reboot_button_dialoglayer_rebooting")
		//% "Reboot initiated"
		: qsTrId("reboot_button_dialoglayer_reboot_initiated")

	//% "Please wait until the device rebooted."
	description: qsTrId("reboot_button_dialoglayer_rebooting_description")

	// On device, dialog cannot be dismissed; just wait until device is rebooted.
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkOnly
	footer.enabled: BackendConnection.type !== BackendConnection.DBusSource
	footer.opacity: footer.enabled ? 1 : 0
}
