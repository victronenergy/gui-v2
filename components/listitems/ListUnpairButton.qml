/*
** Copyright (C) 2026 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

ListButton {
	//% "Unpair"
	secondaryText: qsTrId("devices_pairing_unpair")
	writeAccessLevel: VenusOS.User_AccessType_User
	buttonBorderColor: Theme.color_critical
	buttonBackgroundColor: Theme.color_darkCritical
	buttonColor: Theme.color_darkCritical_text
}
