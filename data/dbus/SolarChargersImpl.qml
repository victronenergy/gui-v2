/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
			id: solarCharger
			serviceUid: model.uid

			onValidChanged: {
				if (!!Global.solarChargers) {
					if (valid) {
						Global.solarChargers.addCharger(solarCharger)
					} else {
						Global.solarChargers.removeCharger(solarCharger)
					}
				}
			}
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
			id: multiRsSolarCharger
			serviceUid: model.uid

			onValidChanged: {
				if (!!Global.solarChargers) {
					if (valid) {
						Global.solarChargers.addCharger(multiRsSolarCharger)
					} else {
						Global.solarChargers.removeCharger(multiRsSolarCharger)
					}
				}
			}
		}
	}
}
