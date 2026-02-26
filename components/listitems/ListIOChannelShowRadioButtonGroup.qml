/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListRadioButtonGroup {
	//: Whether UI controls should be shown for this input/output
	//% "Show controls"
	text: qsTrId("iochannel_showui_controls")
	writeAccessLevel: VenusOS.User_AccessType_User
	preferredVisible: dataItem.valid
	optionModel: [
		{ display: CommonWords.off, value: VenusOS.IOChannel_ShowUI_Off },
		//% "Always"
		{ display: qsTrId("iochannel_showui_always"), value: VenusOS.IOChannel_ShowUI_Always },
		//% "Only local"
		{ display: qsTrId("iochannel_showui_local"), value: VenusOS.IOChannel_ShowUI_Local },
		//% "Only on VRM"
		{ display: qsTrId("iochannel_showui_vrm"), value: VenusOS.IOChannel_ShowUI_Remote }
	]
}
