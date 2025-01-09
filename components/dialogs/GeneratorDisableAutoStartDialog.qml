/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ModalWarningDialog {
	dialogDoneOptions: VenusOS.ModalDialog_DoneOptions_OkAndCancel

	//% "Disable autostart?"
	title: qsTrId("ac-in-genset_disableautostartdialog_title")

	//% "Autostart will be disabled and the generator won't automatically start based on the configured conditions.\nIf the generator is currently running due to a autostart condition, disabling autostart will also stop it immediately."
	description: qsTrId("ac-in-genset_disableautostartdialog_description")
}
