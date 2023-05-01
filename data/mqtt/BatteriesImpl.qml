/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import "../common"

QtObject {
	property Instantiator batteryObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/battery"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Battery {
			serviceUid: model.uid
		}
	}
}
