/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import "../common"

QtObject {
	id: root

	property PvMonitor pvMonitor: PvMonitor {
		model: [
			"dbus/com.victronenergy.system/Ac/PvOnGrid",
			"dbus/com.victronenergy.system/Ac/PvOnGenset",
			"dbus/com.victronenergy.system/Ac/PvOnOutput"
		]
	}

	property SystemData systemData: SystemData {}
}
