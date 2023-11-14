/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
	}
}
