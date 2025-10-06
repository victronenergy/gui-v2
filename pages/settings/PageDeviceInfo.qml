/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	// The uid of the service that provides the device information.
	required property string serviceUid

	// Additional settings to be loaded.
	property Component extraDeviceInfo

	title: CommonWords.device_info_title

	GradientListView {
		model: VisibleItemModel {
			ListText {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				dataItem.uid: root.serviceUid + "/Mgmt/Connection"
				dataItem.invalidate: false
			}

			ListText {
				//% "Product"
				text: qsTrId("settings_deviceinfo_product")
				dataItem.uid: root.serviceUid + "/ProductName"
				dataItem.invalidate: false
			}

			ListTextField {
				//% "Name"
				text: qsTrId("settings_deviceinfo_name")
				dataItem.uid: root.serviceUid + "/CustomName"
				dataItem.invalidate: false
				textField.maximumLength: 32
				preferredVisible: dataItem.valid
				placeholderText: CommonWords.custom_name
				writeAccessLevel: VenusOS.User_AccessType_User
			}

			ListText {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				secondaryText: Utils.toHexFormat(dataItem.value)
				dataItem.uid: root.serviceUid + "/ProductId"
				dataItem.invalidate: false
			}

			ListFirmwareVersion {
				bindPrefix: root.serviceUid
				dataItem.invalidate: false
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				dataItem.uid: root.serviceUid + "/HardwareVersion"
				dataItem.invalidate: false
				preferredVisible: dataItem.valid
			}

			ListText {
				text: CommonWords.vrm_instance
				dataItem.uid: root.serviceUid + "/DeviceInstance"
				dataItem.invalidate: false
			}

			ListText {
				text: CommonWords.serial_number
				dataItem.uid: root.serviceUid + "/Serial"
				dataItem.invalidate: false
				preferredVisible: dataItem.valid
			}

			ListText {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				dataItem.uid: root.serviceUid + "/DeviceName"
				dataItem.invalidate: false
				preferredVisible: dataItem.valid
			}
		}

		footer: root.extraDeviceInfo
	}
}
