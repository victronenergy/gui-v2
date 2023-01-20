/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	SettingsListView {
		model: ObjectModel {
			SettingsListTextItem {
				text: CommonWords.connected
				source: root.bindPrefix + "/Connected"
				secondaryText: dataPoint.value === 1 ? CommonWords.yes : CommonWords.no
			}

			SettingsListTextItem {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				source: root.bindPrefix + "/Mgmt/Connection"
			}

			SettingsListTextItem {
				//% "Product"
				text: qsTrId("settings_deviceinfo_product")
				source: root.bindPrefix + "/ProductName"
			}

			SettingsListTextField {
				//% "Name"
				text: qsTrId("settings_deviceinfo_name")
				source: root.bindPrefix + "/CustomName"
				textField.maximumLength: 32
			}

			SettingsListTextItem {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				source: root.bindPrefix + "/ProductId"
			}

			SettingsListTextItem {
				//% "Firmware version"
				text: qsTrId("settings_deviceinfo_firmware_version")
				source: root.bindPrefix + "/FirmwareVersion"
			}

			SettingsListTextItem {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				source: root.bindPrefix + "/HardwareVersion"
				visible: dataPoint.valid
			}

			SettingsListTextItem {
				//% "VRM instance"
				text: qsTrId("settings_deviceinfo_vrm_instance")
				source: root.bindPrefix + "/DeviceInstance"
			}

			SettingsListTextItem {
				//% "Serial number"
				text: qsTrId("settings_deviceinfo_serial")
				source: root.bindPrefix + "/Serial"
				visible: dataPoint.valid
			}

			SettingsListTextItem {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				source: root.bindPrefix + "/DeviceName"
				visible: dataPoint.valid
			}
		}
	}
}
