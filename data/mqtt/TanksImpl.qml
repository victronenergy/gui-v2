/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	readonly property Instantiator tankObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/tank"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: Tank {
			serviceUid: model.uid
		}
	}
}
