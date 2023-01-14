/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "../common"

QtObject {
	id: root

	property Instantiator generatorObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.generator\."
			model: Global.dataServiceModel
		}

		delegate: Generator {
			serviceUid: model.uid
		}
	}
}
