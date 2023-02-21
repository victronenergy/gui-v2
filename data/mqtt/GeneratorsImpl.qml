/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "../common"

QtObject {
	id: root

	property Instantiator generatorObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/generator"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Generator {
			serviceUid: model.uid
		}

		onObjectAdded: function(index, object) {
			Global.generators.insertGenerator(index, object)
		}

		onObjectRemoved: function(index, object) {
			Global.generators.removeGenerator(index)
		}
	}
}
