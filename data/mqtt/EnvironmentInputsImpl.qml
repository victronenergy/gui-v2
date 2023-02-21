/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "../common"

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/temperature"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: EnvironmentInput {
			serviceUid: model.uid
		}

		onObjectAdded: function(index, object) {
			Global.environmentInputs.insertInput(index, object)
		}

		onObjectRemoved: function(index, object) {
			Global.environmentInputs.removeInput(index)
		}
	}
}
