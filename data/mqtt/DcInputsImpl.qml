/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: [
				"mqtt/alternator",
				"mqtt/fuelcell",
				"mqtt/dcload",
				"mqtt/dcsource",
				"mqtt/dcsystem",
			]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcInput {
			serviceUid: model.uid
		}
	}
}
