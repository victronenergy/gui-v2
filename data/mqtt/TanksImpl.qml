/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

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
