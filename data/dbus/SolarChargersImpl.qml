/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property Instantiator chargerObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.solarcharger\."
			model: Global.dataServiceModel
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}

	property Instantiator multiRsChargerObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.multi\."
			model: Global.dataServiceModel
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}
}
