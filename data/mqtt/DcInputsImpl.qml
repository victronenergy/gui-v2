/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: [
				"mqtt/alternator",
				"mqtt/fuelcell",
				"mqtt/dcsource",
				"mqtt/dcgenset",
			]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcInput {
			serviceUid: model.uid
		}
	}
}
