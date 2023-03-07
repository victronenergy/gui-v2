/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				text: CommonWords.connected
				dataSource: root.bindPrefix + "/Connected"
				secondaryText: dataValue === 1 ? CommonWords.yes : CommonWords.no
			}

			ListTextItem {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				dataSource: root.bindPrefix + "/Mgmt/Connection"
			}

			ListTextItem {
				//% "Product"
				text: qsTrId("settings_deviceinfo_product")
				dataSource: root.bindPrefix + "/ProductName"
			}

			ListTextField {
				//% "Name"
				text: qsTrId("settings_deviceinfo_name")
				dataSource: root.bindPrefix + "/CustomName"
				textField.maximumLength: 32
			}

			ListTextItem {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				dataSource: root.bindPrefix + "/ProductId"
			}

			ListTextItem {
				//% "Firmware version"
				text: qsTrId("settings_deviceinfo_firmware_version")
				dataSource: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				dataSource: root.bindPrefix + "/HardwareVersion"
				visible: dataValid
			}

			ListTextItem {
				//% "VRM instance"
				text: qsTrId("settings_deviceinfo_vrm_instance")
				dataSource: root.bindPrefix + "/DeviceInstance"
			}

			ListTextItem {
				//% "Serial number"
				text: qsTrId("settings_deviceinfo_serial")
				dataSource: root.bindPrefix + "/Serial"
				visible: dataValid
			}

			ListTextItem {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				datadataSource: root.bindPrefix + "/DeviceName"
				visible: dataValid
			}
		}
	}
}
