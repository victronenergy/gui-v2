/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	id: root

	required property string serviceUid

	//% "Start/Stop"
	text: qsTrId("evcs_start_stop")

	secondaryText: startStop.value === 0 ? CommonWords.start_action : CommonWords.stop_action
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: startStop.valid
	onClicked: startStop.setValue(startStop.value === 0 ? 1 : 0)
	interactive: !(startStop.value === 1 && isStopAllowed.valid && isStopAllowed.value === 0)

	VeQuickItem {
		id: startStop
		uid: root.serviceUid + "/StartStop"
	}
	VeQuickItem {
		id: isStopAllowed
		uid: root.serviceUid + "/IsStopAllowed"
	}
}
