/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import "/components/Utils.js" as Utils

Item {
	id: root

	property int accessLevel: User.AccessUser

	function setAccessLevel(value) {
		accessLevel = value
	}
}
