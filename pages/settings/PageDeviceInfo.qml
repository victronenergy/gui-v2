/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import QtQuick.Controls.impl as CP

Page {
	id: root

	property string bindPrefix
	property alias settingsListView: settingsListView

	GradientListView {
		id: settingsListView

		model: ObjectModel {
			ListText {
				//% "Connection"
				text: qsTrId("settings_deviceinfo_connection")
				dataItem.uid: root.bindPrefix + "/Mgmt/Connection"
				dataItem.invalidate: false
				secondaryLabel.rightPadding: connectedIcon.visible ? connectedIcon.width + Theme.geometry_listItem_content_spacing : 0

				CP.ColorImage {
					id: connectedIcon

					anchors {
						right: parent.right
						rightMargin: Theme.geometry_listItem_content_horizontalMargin
						verticalCenter: parent.primaryLabel.verticalCenter
					}
					color: Theme.color_green
					source: "qrc:/images/icon_checkmark_32.svg"
					visible: connectedDataItem.value === 1
				}

				VeQuickItem {
					id: connectedDataItem

					uid: root.bindPrefix + "/Connected"
				}
			}

			ListText {
				//% "Product"
				text: qsTrId("settings_deviceinfo_product")
				dataItem.uid: root.bindPrefix + "/ProductName"
				dataItem.invalidate: false
			}

			ListTextField {
				//% "Name"
				text: qsTrId("settings_deviceinfo_name")
				dataItem.uid: root.bindPrefix + "/CustomName"
				dataItem.invalidate: false
				textField.maximumLength: 32
				allowed: dataItem.isValid
				placeholderText: CommonWords.custom_name
			}

			ListText {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				secondaryText: Utils.toHexFormat(dataItem.value)
				dataItem.uid: root.bindPrefix + "/ProductId"
				dataItem.invalidate: false
			}

			ListFirmwareVersionItem {
				bindPrefix: root.bindPrefix
				dataItem.invalidate: false
			}

			ListText {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				dataItem.uid: root.bindPrefix + "/HardwareVersion"
				dataItem.invalidate: false
				allowed: dataItem.isValid
			}

			ListText {
				text: CommonWords.vrm_instance
				dataItem.uid: root.bindPrefix + "/DeviceInstance"
				dataItem.invalidate: false
			}

			ListText {
				text: CommonWords.serial_number
				dataItem.uid: root.bindPrefix + "/Serial"
				dataItem.invalidate: false
				allowed: dataItem.isValid
			}

			ListText {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				dataItem.uid: root.bindPrefix + "/DeviceName"
				dataItem.invalidate: false
				allowed: dataItem.isValid
			}
		}
	}
}
