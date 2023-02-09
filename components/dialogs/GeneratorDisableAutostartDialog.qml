/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

ModalWarningDialog {
	id: root

	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

	//% "Disable Autostart?"
	title: qsTrId("controlcard_generator_disableautostartdialog_title")

	// TODO set text to something meaningful
	//% "Consequences description..."
	description: qsTrId("controlcard_generator_disableautostartdialog_consequences")
}
