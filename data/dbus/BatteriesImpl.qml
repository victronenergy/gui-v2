/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "../common"

QtObject {
	property Instantiator batteryObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.battery\."
			model: Global.dataServiceModel
		}

		delegate: Battery {
			serviceUid: model.uid
		}
	}

	property Instantiator multiRsBatteryObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.multi\."
			model: Global.dataServiceModel
		}

		delegate: Battery {
			serviceUid: model.uid
		}
	}
}
