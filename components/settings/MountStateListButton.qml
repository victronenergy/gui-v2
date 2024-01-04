/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListButton {
	id: root

	function _mountStateToText(s) {
		switch (s) {
		case VenusOS.Storage_Mounted:
			//% "Press to eject"
			return qsTrId("components_mount_state_press_to_eject")
		case VenusOS.Storage_UnmountRequested:
		case VenusOS.Storage_UnmountBusy:
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
	button.enabled: mountState.value === VenusOS.Storage_Mounted
	writeAccessLevel: VenusOS.User_AccessType_User

	onClicked: mountState.setValue(VenusOS.Storage_UnmountRequested)

	VeQuickItem {
		id: mountState

		uid: BackendConnection.serviceUidForType("logger") + "/Storage/MountState"
	}
}
