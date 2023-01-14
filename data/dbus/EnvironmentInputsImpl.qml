/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.Veutil
import Victron.VenusOS
import "../common"

QtObject {
	id: root

	property Instantiator inputObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.temperature\."
			model: Global.dataServiceModel
		}
		delegate: EnvironmentInput {
			serviceUid: model.uid
		}
	}
}
