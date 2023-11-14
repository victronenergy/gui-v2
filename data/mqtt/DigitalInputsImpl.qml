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

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/digitalinput"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}
		delegate: DigitalInput {
			serviceUid: model.uid
		}
	}
}
