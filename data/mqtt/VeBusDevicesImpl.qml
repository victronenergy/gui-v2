/*
** Copyright (C) 2023 Victron Energy B.V.
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

		delegate: VeBusDevice {
			serviceUid: model.uid
		}
	}

	property Instantiator multiRsInverterObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/multi"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: VeBusDevice {
			serviceUid: model.uid
		}
	}
}
