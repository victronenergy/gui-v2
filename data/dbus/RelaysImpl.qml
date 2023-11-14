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

	property Instantiator relayObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["dbus/com.victronenergy.system/Relay"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: Relay {
			serviceUid: model.uid
			relayIndex: model.index
		}
	}
}
