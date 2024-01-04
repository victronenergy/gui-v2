/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil

Page {
	id: root

	property string bindPrefix

	//% "Smappee bus devices"
	title: qsTrId("smappee_device_list_bus_devices")

	GradientListView {
		model: VeQItemSortTableModel {
			filterFlags: VeQItemSortTableModel.FilterOffline
			dynamicSortFilter: true
			model: VeQItemTableModel {
				uids: [ root.bindPrefix + "/Device" ]
				flags: VeQItemTableModel.AddChildren
					   | VeQItemTableModel.AddNonLeaves
					   | VeQItemTableModel.DontAddItem
			}
		}

		delegate: ListTextItem {
			id: menu

			readonly property int devIndex: model.id

			text: (devIndex + 1) + ": " + (type.value || "")

			VeQuickItem {
				id: type
				uid: model.uid + "/Type"
			}
		}
	}
}
