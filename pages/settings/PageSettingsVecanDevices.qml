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
		model: VeQItemTableModel {
			uids: [ root.serviceUid + "/Devices" ]
			flags: VeQItemTableModel.AddChildren | VeQItemTableModel.AddNonLeaves | VeQItemTableModel.DontAddItem
		}

		delegate: ListNavigation {
			id: listDelegate

			required property string uid

			// Use JS string concatenation to avoid Qt string arg() from formatting as scientific notation.
			text: "%1 [%2]".arg(customName.value || modelName.value).arg(""+uniqueNumber.value)
			//% "VE.Can Instance# %1"
			secondaryText: qsTrId("settings_vecan_device_number").arg(deviceInstance.value)

			onClicked: Global.pageManager.pushPage("/pages/settings/PageSettingsVecanDevice.qml",
												   { bindPrefix: listDelegate.uid, title: text })

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
