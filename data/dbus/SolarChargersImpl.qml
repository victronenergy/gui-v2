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
			"dbus/com.victronenergy.system/Ac/PvOnGrid",
			"dbus/com.victronenergy.system/Ac/PvOnGenset",
			"dbus/com.victronenergy.system/Ac/PvOnOutput"
		]
	}

	property Instantiator chargerObjects: Instantiator {
		model: VeQItemSortTableModel {
			id: solarChargerModel

			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.solarcharger\."
			model: Global.dataServiceModel
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}
}
