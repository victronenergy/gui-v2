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

	// ActiveInput value is 0-based index.
	secondaryText: acActiveInput.valid ? CommonWords.acInputFromIndex(acActiveInput.value) : CommonWords.disconnected
}
