/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick

QtObject {
	id: root

	property PvMonitor pvMonitor: PvMonitor {
		model: [
			"mqtt/system/0/Ac/PvOnGrid",
			"mqtt/system/0/Ac/PvOnGenset",
			"mqtt/system/0/Ac/PvOnOutput"
		]
	}

	property SystemData systemData: SystemData {}
}
