/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator vebusInverterObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.vebus\."
			model: Global.dataServiceModel
		}

		delegate: InverterCharger {
			id: veBusDevice

			serviceUid: model.uid

			onValidChanged: {
				if (valid) {
					Global.inverterChargers.veBusDevices.addDevice(veBusDevice)
				} else {
					Global.inverterChargers.veBusDevices.removeDevice(veBusDevice)
				}
			}
		}
	}

	property Instantiator multiObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.multi\."
			model: Global.dataServiceModel
		}

		delegate: InverterCharger {
			id: multiDevice

			serviceUid: model.uid

			onValidChanged: {
				if (valid) {
					Global.inverterChargers.multiDevices.addDevice(multiDevice)
				} else {
					Global.inverterChargers.multiDevices.removeDevice(multiDevice)
				}
			}
		}
	}

	property Instantiator inverterObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.inverter\."
			model: Global.dataServiceModel
		}

		delegate: Inverter {
			id: inverterDevice

			serviceUid: model.uid

			onValidChanged: {
				if (valid) {
					Global.inverterChargers.inverterDevices.addDevice(inverterDevice)
				} else {
					Global.inverterChargers.inverterDevices.removeDevice(inverterDevice)
				}
			}
		}
	}
}
