/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string serviceUid

	//% "RV-C devices"
	title: qsTrId("settings_rvc_devices")

	GradientListView {
		model: VeQItemTableModel {
			uids: [ root.serviceUid + "/Devices" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
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
