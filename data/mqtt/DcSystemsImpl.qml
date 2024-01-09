/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	model: VeQItemTableModel {
		uids: ["mqtt/dcsystem"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	delegate: DcSystem {
		serviceUid: model.uid
	}
}
