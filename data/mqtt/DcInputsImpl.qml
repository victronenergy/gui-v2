/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemTableModel {
			uids: ["mqtt/alternator", "mqtt/fuelcell", "mqtt/dcsource"]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: DcInput {
			serviceUid: model.uid
			source: {
				if (model.uid.startsWith("mqtt/alternator")) {
					return VenusOS.DcInputs_InputType_Alternator
				} else if (model.uid.startsWith("mqtt/fuelcell")) {
					return VenusOS.DcInputs_InputType_FuelCell
				} else if (model.uid.startsWith("mqtt/dcsource")) {
					// Use DC Generator as the catch-all type for any DC power source that isn't
					// specifically handled.
					return allMonitorModes[monitorMode.toString()] || VenusOS.DcInputs_InputType_DcGenerator
				}
				return VenusOS.DcInputs_InputType_Unknown
			}
		}
	}
}
