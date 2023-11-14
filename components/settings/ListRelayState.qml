/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextItem {
	//% "Relay state"
	text: qsTrId("list_relay_state")
	visible: defaultVisible && dataValid
	secondaryText: CommonWords.onOrOff(dataValue)
}
