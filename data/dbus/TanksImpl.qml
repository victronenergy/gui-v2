/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	id: root

	property Instantiator tankObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.tank\."
			model: Global.dataServiceModel
		}

		delegate: Tank {
			serviceUid: model.uid
		}
	}
}
