/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	property int updateType

	button.text: Global.firmwareUpdate.state === FirmwareUpdater.Checking
			 //% "Checking..."
		   ? qsTrId("settings_firmware_checking")
			 //% "Press to check"
		   : qsTrId("settings_firmware_press_to_check")
	enabled: !Global.firmwareUpdate.busy
	writeAccessLevel: VenusOS.User_AccessType_User

	onClicked: {
		Global.firmwareUpdate.checkForUpdate(updateType)
	}
}
