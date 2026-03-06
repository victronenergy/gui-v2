/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	required property string bindPrefix

	IpAddressListView {
		addressesUid: root.bindPrefix + "/IpAddresses"
		writeAccessLevel: VenusOS.User_AccessType_User
	}
}
