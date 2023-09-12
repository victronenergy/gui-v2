/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS
import Victron.Veutil
import Victron.Utils

Page {
	id: root

	property string gateway

	readonly property string _dbusDevicesUid: "dbus/com.victronenergy.vecan." + gateway + "/Devices"

	//% "VE.CAN devices"
	title: qsTrId("settings_vecan_devices")

	SingleUidHelper {
		id: vecanUidHelper
		dbusUid: root._dbusDevicesUid
	}

	GradientListView {
		model: VeQItemSortTableModel {
			filterFlags: VeQItemSortTableModel.FilterOffline
			dynamicSortFilter: true
			model: VeQItemTableModel {
				uids: BackendConnection.type === BackendConnection.DBusSource
					  ? [root._dbusDevicesUid]
					  : BackendConnection.type === BackendConnection.MqttSource
						? [vecanUidHelper.mqttUid]
						: ""
				flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
			}
		}

		delegate: ListSpinBox {
			id: listDelegate

			text: "%1 [%2]".arg(customName.value || modelName.value).arg(uniqueNumber.value)
			//% "Device# %1"
			secondaryText: qsTrId("settings_vecan_device_number").arg(dataValue)
			dataSource: model.uid + "/DeviceInstance"

			CP.ColorImage {
				parent: listDelegate.content
				anchors.verticalCenter: parent.verticalCenter
				source: "/images/icon_back_32.svg"
				rotation: 180
				color: listDelegate.containsPress ? Theme.color.listItem.down.forwardIcon : Theme.color.listItem.forwardIcon
			}

			MouseArea {
				id: mouseArea

				parent: listDelegate.backgroundRect
				anchors.fill: parent
				onClicked: {
					Global.pageManager.pushPage("qrc:/qt/qml/Victron/VenusOS/pages/settings/PageSettingsVecanDevice.qml",
						{ bindPrefix: model.uid, title: text })
				}
			}

			VeQuickItem {
				id: modelName
				uid: model.uid + "/ModelName"
			}

			VeQuickItem {
				id: customName
				uid: model.uid + "/CustomName"
			}

			VeQuickItem {
				id: uniqueNumber
				uid: model.uid + "/N2kUniqueNumber"
			}
		}
	}
}
