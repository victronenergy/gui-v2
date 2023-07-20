/*
** Copyright (C) 2023 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {
			ListTextItem {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				dataSource: root.bindPrefix + "/Mgmt/Connection"
				secondaryLabel.rightPadding: connectedIcon.visible ? connectedIcon.width + Theme.geometry.listItem.content.spacing : 0

				CP.ColorImage {
					id: connectedIcon

					anchors {
						right: parent.right
						rightMargin: Theme.geometry.listItem.content.horizontalMargin
						verticalCenter: parent.primaryLabel.verticalCenter
					}
					color: Theme.color.green
					source: "/images/icon_checkmark_32.svg"
					visible: connectedDataPoint.value === 1
				}

				DataPoint {
					id: connectedDataPoint

					source: root.bindPrefix + "/Connected"
				}
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
				//% "Custom name"
				placeholderText: qsTrId("settings_deviceinfo_custom_name")
			}

			ListTextItem {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				dataSource: root.bindPrefix + "/ProductId"

				// Value should be shown in hex. TODO can use VeQuickItem::text instead to auto
				// show the hex text value from the backend, when that is available via MQTT.
				secondaryText: dataValue ? "0x" + dataValue.toString(16).toUpperCase() : ""
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
				dataSource: root.bindPrefix + "/DeviceName"
				visible: dataValid
			}
		}
	}
}
