/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	model: VeQItemSortTableModel {
		dynamicSortFilter: true
		filterRole: VeQItemTableModel.UniqueIdRole
		filterRegExp: "^dbus/com\.victronenergy\.dcload\."
		model: Global.dataServiceModel
	}

	delegate: DcLoad {
		serviceUid: model.uid
	}
}
