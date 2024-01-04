/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

ListTextItem {
	property var veBusDevice

	VeQuickItem {
		id: acActiveInput

		uid: veBusDevice.serviceUid + "/Ac/ActiveIn/ActiveInput"
	}

	//% "Active AC Input"
	text: qsTrId("vebus_device_active_ac_input")
	secondaryText: {
		switch(acActiveInput.value) {
		case 0:
		case 1:
			//% "AC in %1"
			return qsTrId("vebus_device_page_ac_in").arg(acActiveInput.value + 1)
		default:
			return CommonWords.disconnected
		}
	}
}
