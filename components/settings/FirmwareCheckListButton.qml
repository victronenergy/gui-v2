/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListButton {
	id: root

	property int updateType
	property FirmwareUpdate firmwareUpdate

	button.text: firmwareUpdate.state === FirmwareUpdater.Checking
			 //% "Checking..."
		   ? qsTrId("settings_firmware_checking")
			 //% "Press to check"
		   : qsTrId("settings_firmware_press_to_check")
	enabled: !firmwareUpdate.busy
	writeAccessLevel: VenusOS.User_AccessType_User

	onClicked: {
		firmwareUpdate.checkForUpdate(updateType)
	}
}
