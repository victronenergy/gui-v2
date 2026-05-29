/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	property int updateType

	secondaryText: Global.firmwareUpdate.checkingForUpdate
			 //% "Checking..."
		   ? qsTrId("settings_firmware_checking")
		   : CommonWords.check_now
	interactive: !Global.firmwareUpdate.checkingForUpdate
	writeAccessLevel: VenusOS.User_AccessType_User

	onClicked: {
		Global.firmwareUpdate.checkForUpdate(updateType)
	}
}
