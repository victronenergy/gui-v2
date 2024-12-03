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
					Global.inverterChargers.veBusDevices.removeDevice(veBusDevice.serviceUid)
				}
			}
		}
	}

	property Instantiator multiObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.acsystem\."
			model: Global.dataServiceModel
		}

		delegate: InverterCharger {
			id: acSystemDevice

			serviceUid: model.uid

			onValidChanged: {
				if (valid) {
					Global.inverterChargers.acSystemDevices.addDevice(acSystemDevice)
				} else {
					Global.inverterChargers.acSystemDevices.removeDevice(acSystemDevice.serviceUid)
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
					Global.inverterChargers.inverterDevices.removeDevice(inverterDevice.serviceUid)
				}
			}
		}
	}

	property Instantiator chargerObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.charger\."
			model: Global.dataServiceModel
		}

		delegate: Device {
			id: chargerDevice

			serviceUid: model.uid

			onValidChanged: {
				if (valid) {
					Global.inverterChargers.chargerDevices.addDevice(chargerDevice)
				} else {
					Global.inverterChargers.chargerDevices.removeDevice(chargerDevice.serviceUid)
				}
			}
		}
	}
}
