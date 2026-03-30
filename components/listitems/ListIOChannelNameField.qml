/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	//% "Name"
	text: qsTrId("iochannel_name")
	dataItem.invalidate: false
	writeAccessLevel: VenusOS.User_AccessType_User
	maximumLength: 32
	preferredVisible: dataItem.valid
	placeholderText: CommonWords.custom_name
}
