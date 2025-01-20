/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	VeQItemSortTableModel {
		id: dbusOrMockGpsModel

		dynamicSortFilter: true
		filterFlags: VeQItemSortTableModel.FilterOffline
		filterRole: VeQItemTableModel.IdRole
		filterRegExp: "^com\.victronenergy\.gps"
		model: BackendConnection.type !== BackendConnection.MqttSource ? Global.dataServiceModel : null
	}

	VeQItemTableModel {
		id: mqttGpsModel

		uids: BackendConnection.type === BackendConnection.MqttSource ? ["mqtt/gps"] : []
		flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
	}

	GradientListView {
		model: BackendConnection.type === BackendConnection.MqttSource ? mqttGpsModel : dbusOrMockGpsModel
		delegate: ListNavigation {
			text: (productName.isValid && vrmInstance.isValid)
				  ? `${productName.value} [${vrmInstance.value}]`
				  : "--"

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageGps.qml",
						{"title": text, bindPrefix: model.uid })
			}

			VeQuickItem {
				id: productName
				uid: model.uid + "/ProductName"
			}

			VeQuickItem {
				id: vrmInstance
				uid: model.uid + "/DeviceInstance"
			}
		}
	}
}
