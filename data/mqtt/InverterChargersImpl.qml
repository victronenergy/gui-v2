/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator vebusInverterObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/vebus"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
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

	property Instantiator multiRsInverterObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/multi"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
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
		model: VeQItemTableModel {
			uids: ["mqtt/inverter"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
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
