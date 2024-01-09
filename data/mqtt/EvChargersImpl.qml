/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

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
