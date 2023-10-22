/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator objects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/pulsemeter"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: PulseMeter {
			serviceUid: model.uid
		}
	}
}
