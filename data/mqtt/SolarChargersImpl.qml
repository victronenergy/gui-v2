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
			uids: ["mqtt/solarcharger"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}

	property Instantiator multiRsChargerObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/multi"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: SolarCharger {
			serviceUid: model.uid
		}
	}
}
