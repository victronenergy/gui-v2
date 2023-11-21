/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Instantiator {
	id: root

	model: VeQItemTableModel {
		uids: ["mqtt/dcload"]
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	delegate: DcLoad {
		serviceUid: model.uid
	}
}
