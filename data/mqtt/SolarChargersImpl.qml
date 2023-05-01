
/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
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

	property Instantiator chargerObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/solarcharger"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}
}
