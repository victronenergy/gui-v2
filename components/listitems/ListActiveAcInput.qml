/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	id: root

	property string bindPrefix

	VeQuickItem {
		id: acActiveInput

		uid: root.bindPrefix + "/Ac/ActiveIn/ActiveInput"
	}

	//% "Active AC Input"
	text: qsTrId("vebus_device_active_ac_input")
	secondaryText: {
		switch (acActiveInput.value) {
		case 0:
		case 1:
			return CommonWords.acInput(acActiveInput.value)
		default:
			return CommonWords.disconnected
		}
	}
}
