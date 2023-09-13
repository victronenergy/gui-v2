/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.(alternator|fuelcell|dcsource)\."
			model: Global.dataServiceModel
		}

		delegate: DcInput {
			serviceUid: model.uid
			source: {
				if (model.uid.startsWith("dbus/com.victronenergy.alternator.")) {
					return VenusOS.DcInputs_InputType_Alternator
				} else if (model.uid.startsWith("dbus/com.victronenergy.fuelcell.")) {
					return VenusOS.DcInputs_InputType_FuelCell
				} else if (model.uid.startsWith("dbus/com.victronenergy.dcsource.")) {
					// Use DC Generator as the catch-all type for any DC power source that isn't
					// specifically handled.
					return allMonitorModes[monitorMode.toString()] || VenusOS.DcInputs_InputType_DcGenerator
				}
				return VenusOS.DcInputs_InputType_Unknown
			}
		}
	}
}
