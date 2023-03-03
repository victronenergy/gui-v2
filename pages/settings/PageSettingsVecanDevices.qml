/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
import "/components/Utils.js" as Utils

Page {
	id: root

	property string gateway

	//% "VE.CAN devices"
	title: qsTrId("settings_vecan_devices")

	GradientListView {
		model: VeQItemSortTableModel {
			filterFlags: VeQItemSortTableModel.FilterOffline
			dynamicSortFilter: true
			model: VeQItemTableModel {
				// TODO fix this 'uids' for MQTT, else will crash in MQTT mode
				uids: ["dbus/com.victronenergy.vecan." + root.gateway + "/Devices"]
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: ListNavigationItem {
			text: "%1 [%2]".arg(customName.value || modelName.value).arg(uniqueNumber.value)
			//% "Device# %1"
			secondaryText: qsTrId("settings_vecan_device_number").arg(deviceInstance.value)

			DataPoint {
				id: modelName
				source: Utils.normalizedSource(model.uid) + "/ModelName"
			}

			DataPoint {
				id: customName
				source: Utils.normalizedSource(model.uid) + "/CustomName"
			}

			DataPoint {
				id: uniqueNumber
				source: Utils.normalizedSource(model.uid) + "/N2kUniqueNumber"
			}

			DataPoint {
				id: deviceInstance
				source: model.uid + "/DeviceInstance"
			}

			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsVecanDevice.qml",
					{ bindPrefix: Utils.normalizedSource(model.uid), title: text })
			}
		}
	}
}
