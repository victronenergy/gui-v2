/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Page {
	id: root

	property string gateway

	//% "RV-C devices"
	title: qsTrId("settings_rvc_devices")

	GradientListView {
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterFlags: VeQItemSortTableModel.FilterOffline
			model: VeQItemTableModel {
				uids: BackendConnection.type === BackendConnection.DBusSource
					  ? ["dbus/com.victronenergy.rvc." + root.gateway + "/Devices"]
					  : BackendConnection.type === BackendConnection.MqttSource
						? ["mqtt/rvc/0/Devices"]    // TODO this should change depending on the gateway!
						: ""
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: ListNavigationItem {
			text: {
				let name = modelName.value || ""
				if (vrmInstance.value) {
					name += "[VRM# %1]".arg(vrmInstance.value)
				}
				return name
			}
			secondaryText: Utils.toHexFormat(nad.value)

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsRvcDevice.qml",
					{ bindPrefix: model.uid, title: modelName.value || "" })
			}

			VeQuickItem {
				id: modelName
				uid: model.uid + "/ModelName"
			}

			VeQuickItem {
				id: nad
				uid: model.uid + "/Nad"
			}

			VeQuickItem {
				id: vrmInstance
				uid: model.uid + "/VrmInstance"
			}
		}
	}
}
