/*
** Copyright (C) 2024 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string modbusService: BackendConnection.serviceUidFromName("com.victronenergy.modbusclient.tcp", 0)


	property VeQItemSortTableModel devices: VeQItemSortTableModel {
		model: VeQItemTableModel {
			uids: [modbusService + "/Devices"]
			flags: VeQItemTableModel.AddChildren |
				   VeQItemTableModel.AddNonLeaves |
				   VeQItemTableModel.DontAddItem
		}
		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
	}

	GradientListView {
		id: listView
		header: ListLabel {
			horizontalAlignment: Text.AlignHCenter
			allowed: listView.count === 0
			//% "No Modbus devices discovered"
			text: qsTrId("settings_modbus_no_devices_discovered")
		}
		model: VeQItemSortTableModel {
			model: VeQItemChildModel {
				model: devices
				childId: "Name"
			}
			dynamicSortFilter: true
			filterFlags: VeQItemSortTableModel.FilterInvalid
		}
		delegate: ListSwitch {
			dataItem.uid: model.item.itemParent().uid + "/Enabled"
			text: model.item.value
		}
	}
}
