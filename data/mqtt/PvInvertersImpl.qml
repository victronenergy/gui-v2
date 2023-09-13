
/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property Instantiator inverterObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/pvinverter"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: PvInverter {
			serviceUid: model.uid
		}
	}
}
