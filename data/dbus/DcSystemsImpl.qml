/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Instantiator {
	id: root

	model: VeQItemSortTableModel {
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "^dbus/com\.victronenergy\.dcsystem\."
		model: Global.dataServiceModel
	}

	delegate: DcSystem {
		serviceUid: model.uid
	}
}