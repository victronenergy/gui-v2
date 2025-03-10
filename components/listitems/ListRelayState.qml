/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListText {
	//% "Relay state"
	text: qsTrId("list_relay_state")
	preferredVisible: dataItem.valid
	secondaryText: CommonWords.onOrOff(dataItem.value)
}
