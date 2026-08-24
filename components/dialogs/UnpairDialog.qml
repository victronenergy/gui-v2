/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalWarningDialog {
	required property string name

	//% "Unpairing %1"
	title: qsTrId("unpairing_confirm_title").arg(name)

	//% "This will disconnect the device and it will need to be paired again to reconnect."
	description: qsTrId("unpairing_confirm_description")
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel
}
