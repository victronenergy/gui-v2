/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	function _mountStateToText(s) {
		switch (s) {
		case Enums.Storage_Mounted:
			//% "Press to eject"
			return qsTrId("components_mount_state_press_to_eject")
		case Enums.Storage_UnmountRequested:
		case Enums.Storage_UnmountBusy:
			//% "Ejecting, please wait"
			return qsTrId("components_mount_state_ejecting")
		default:
			//% "No storage found"
			return qsTrId("components_mount_state_no_storage_found");
		}
	}

	//% "microSD / USB"
	text: qsTrId("components_mount_state_microsd_usb")
	button.text: _mountStateToText(mountState.value)
	button.enabled: mountState.value === Enums.Storage_Mounted
	writeAccessLevel: Enums.User_AccessType_User

	onClicked: mountState.setValue(Enums.Storage_UnmountRequested)

	DataPoint {
		id: mountState

		source: "com.victronenergy.logger/Storage/MountState"
	}
}
