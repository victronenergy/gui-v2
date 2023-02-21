/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator inverterObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.vebus\."
			model: Global.dataServiceModel
		}

		delegate: Inverter {
			serviceUid: model.uid
		}

		onObjectAdded: function(index, object) {
			Global.inverters.insertInverter(index, object)
		}

		onObjectRemoved: function(index, object) {
			Global.inverters.removeInverter(index)
		}
	}
}
