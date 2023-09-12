/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP
import Victron.Utils

Page {
	id: root

	property string bindPrefix
	property alias settingsListView: settingsListView

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListTextItem {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				dataSource: root.bindPrefix + "/Mgmt/Connection"
				dataInvalidate: false
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
				dataInvalidate: false
			}

			ListTextField {
				//% "Name"
				text: qsTrId("settings_deviceinfo_name")
				dataSource: root.bindPrefix + "/CustomName"
				dataInvalidate: false
				textField.maximumLength: 32
				placeholderText: CommonWords.custom_name
			}

			ListTextItem {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				secondaryText: Utils.toHexFormat(dataValue)
				dataSource: root.bindPrefix + "/ProductId"
				dataInvalidate: false
			}

			ListFirmwareVersionItem {
				dataSource: root.bindPrefix + "/FirmwareVersion"
				dataInvalidate: false
			}

			ListTextItem {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				dataSource: root.bindPrefix + "/HardwareVersion"
				dataInvalidate: false
				visible: dataValid
			}

			ListTextItem {
				text: CommonWords.vrm_instance
				dataSource: root.bindPrefix + "/DeviceInstance"
				dataInvalidate: false
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataSource: root.bindPrefix + "/Serial"
				dataInvalidate: false
				visible: dataValid
			}

			ListTextItem {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				dataSource: root.bindPrefix + "/DeviceName"
				dataInvalidate: false
				visible: dataValid
			}
		}
	}
}
