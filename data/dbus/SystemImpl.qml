/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
