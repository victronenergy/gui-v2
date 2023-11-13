/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	//% "Relay state"
	text: qsTrId("list_relay_state")
	visible: defaultVisible && dataValid
	secondaryText: CommonWords.onOrOff(dataValue)
}
