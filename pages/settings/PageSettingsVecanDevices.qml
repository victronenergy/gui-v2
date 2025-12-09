/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Page {
	id: root

	property string serviceUid

	//% "VE.CAN devices"
	title: qsTrId("settings_vecan_devices")

	GradientListView {
		// Filter out any disconnected/offline devices, i.e. those with an invalid DeviceInstance.
		model: VeQItemSortTableModel {
			dynamicSortFilter: true
			filterFlags: VeQItemSortTableModel.FilterInvalid
			model: VeQItemChildModel {
				model: VeQItemTableModel {
					uids: [ root.serviceUid + "/Devices" ]
					flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
				}
				childId: "DeviceInstance"
			}
		}

		delegate: ListNavigation {
			id: listDelegate

			required property VeQItem item
			readonly property string uid: item.itemParent().uid

			// Use JS string concatenation to avoid Qt string arg() from formatting as scientific notation.
			text: "%1 [%2]".arg(customName.value || modelName.value).arg(""+uniqueNumber.value)

			secondaryText: connected.valid && connected.value === 0 ? CommonWords.offline :
				//% "VE.Can Instance# %1"
				qsTrId("settings_vecan_device_number").arg(deviceInstance.value)

			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsVecanDevice.qml",
												   { bindPrefix: listDelegate.uid, title: text })

			VeQuickItem {
				id: connected
				uid: listDelegate.uid + "/Connected"
			}

			VeQuickItem {
				id: deviceInstance
				uid: listDelegate.uid + "/DeviceInstance"
			}

			VeQuickItem {
				id: modelName
				uid: listDelegate.uid + "/ModelName"
			}

			VeQuickItem {
				id: customName
				uid: listDelegate.uid + "/CustomName"
			}

			VeQuickItem {
				id: uniqueNumber
				uid: listDelegate.uid + "/N2kUniqueNumber"
			}
		}
	}
}
