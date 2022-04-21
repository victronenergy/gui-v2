/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Velib
import "/components/Utils.js" as Utils

Item {
	id: root

	readonly property int accessLevel: veAccessLevel.value || -1

	function setAccessLevel(value) {
		veAccessLevel.setValue(value)
	}

	VeQuickItem {
		id: veAccessLevel
		uid: veSettings.childUId("/Settings/System/AccessLevel")
	}
}
