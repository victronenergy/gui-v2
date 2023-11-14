/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import "../common"

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
