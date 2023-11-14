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

	property Instantiator objects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/motordrive"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: MotorDrive {
			serviceUid: model.uid
		}
	}
}
