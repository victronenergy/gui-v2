/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	property Instantiator batteryObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.battery\."
			model: Global.dataServiceModel
		}

		delegate: Battery {
			id: battery
			serviceUid: model.uid

			onValidChanged: {
				if (!!Global.batteries) {
					if (valid) {
						Global.batteries.addBattery(battery)
					} else {
						Global.batteries.removeBattery(battery)
					}
				}
			}
		}
	}
}
