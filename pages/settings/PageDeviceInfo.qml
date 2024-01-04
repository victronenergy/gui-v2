/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS
import Victron.Veutil
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
					source: "/images/icon_checkmark_32.svg"
					visible: connectedDataItem.value === 1
				}

				VeQuickItem {
					id: connectedDataItem

					uid: root.bindPrefix + "/Connected"
				}
			}

			ListTextItem {
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
				placeholderText: CommonWords.custom_name
			}

			ListTextItem {
				//% "Product ID"
				text: qsTrId("settings_deviceinfo_product_id")
				secondaryText: Utils.toHexFormat(dataItem.value)
				dataItem.uid: root.bindPrefix + "/ProductId"
				dataItem.invalidate: false
			}

			ListFirmwareVersionItem {
				dataItem.uid: root.bindPrefix + "/FirmwareVersion"
				dataItem.invalidate: false
			}

			ListTextItem {
				//% "Hardware version"
				text: qsTrId("settings_deviceinfo_hardware_version")
				dataItem.uid: root.bindPrefix + "/HardwareVersion"
				dataItem.invalidate: false
				visible: dataItem.isValid
			}

			ListTextItem {
				text: CommonWords.vrm_instance
				dataItem.uid: root.bindPrefix + "/DeviceInstance"
				dataItem.invalidate: false
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataItem.uid: root.bindPrefix + "/Serial"
				dataItem.invalidate: false
				visible: dataItem.isValid
			}

			ListTextItem {
				//% "Device name"
				text: qsTrId("settings_deviceinfo_device_name")
				dataItem.uid: root.bindPrefix + "/DeviceName"
				dataItem.invalidate: false
				visible: dataItem.isValid
			}
		}
	}
}
