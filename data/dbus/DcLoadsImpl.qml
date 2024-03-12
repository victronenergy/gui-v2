/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Instantiator {
	id: root

	readonly property Instantiator dcloadObjects: Instantiator {
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

	readonly property Instantiator dcsystemObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.dcsystem\."
			model: Global.dataServiceModel
		}

		delegate: DcLoad {
			serviceUid: model.uid
		}
	}

	readonly property Instantiator dcdcObjects: Instantiator {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterRole: VeQItemTableModel.UniqueIdRole
			filterRegExp: "^dbus/com\.victronenergy\.dcdc\."
			model: Global.dataServiceModel
		}

		delegate: DcLoad {
			serviceUid: model.uid
		}
	}
}
