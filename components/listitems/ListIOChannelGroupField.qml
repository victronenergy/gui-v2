/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListTextField {
	//% "Group"
	text: qsTrId("page_generic_input_group")
	dataItem.invalidate: false
	writeAccessLevel: VenusOS.User_AccessType_User
	textField.maximumLength: 32
	preferredVisible: dataItem.valid
	placeholderText: text
}
