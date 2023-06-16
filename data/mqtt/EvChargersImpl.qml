/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator chargerObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/evcharger"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: EvCharger {
			serviceUid: model.uid
		}
	}
}
