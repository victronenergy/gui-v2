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

	VeQuickItem {
		id: deviceNameItem
		uid: root.serviceUid + "/DeviceName"
	}
	VeQuickItem {
		id: serialItem
		uid: root.serviceUid + "/Serial"
	}
	VeQuickItem {
		id: hardwareVersionItem
		uid: root.serviceUid + "/HardwareVersion"
	}
	VeQuickItem {
		id: customNameItem
		uid: root.serviceUid + "/CustomName"
	}

	title: CommonWords.device_info_title

	GradientListView {
		model: DelegateComponentModel {
			DelegateComponent {
				ListText {
					//% "Connection"
					text: qsTrId("settings_deviceinfo_connection")
					dataItem.uid: root.serviceUid + "/Mgmt/Connection"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				ListText {
					//% "Product"
					text: qsTrId("settings_deviceinfo_product")
					dataItem.uid: root.serviceUid + "/ProductName"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				preferredVisible: customNameItem.valid
				ListTextField {
					//% "Name"
					text: qsTrId("settings_deviceinfo_name")
					dataItem.uid: root.serviceUid + "/CustomName"
					dataItem.invalidate: false
					maximumLength: 32
					placeholderText: CommonWords.custom_name
					writeAccessLevel: VenusOS.User_AccessType_User
				}
			}

			DelegateComponent {
				ListText {
					//% "Product ID"
					text: qsTrId("settings_deviceinfo_product_id")
					secondaryText: Utils.toHexFormat(dataItem.value)
					dataItem.uid: root.serviceUid + "/ProductId"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				dataItem: VeQuickItem { uid: root.serviceUid + "/FirmwareVersion" }
				preferredVisible: dataItem.valid
				ListFirmwareVersion {
					bindPrefix: root.serviceUid
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				preferredVisible: hardwareVersionItem.valid
				ListText {
					//% "Hardware version"
					text: qsTrId("settings_deviceinfo_hardware_version")
					dataItem.uid: root.serviceUid + "/HardwareVersion"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				ListText {
					text: CommonWords.vrm_instance
					dataItem.uid: root.serviceUid + "/DeviceInstance"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				preferredVisible: serialItem.valid
				ListText {
					text: CommonWords.serial_number
					dataItem.uid: root.serviceUid + "/Serial"
					dataItem.invalidate: false
				}
			}

			DelegateComponent {
				preferredVisible: deviceNameItem.valid
				ListText {
					//% "Device name"
					text: qsTrId("settings_deviceinfo_device_name")
					dataItem.uid: root.serviceUid + "/DeviceName"
					dataItem.invalidate: false
				}
			}
		}

		footer: root.extraDeviceInfo
	}
}