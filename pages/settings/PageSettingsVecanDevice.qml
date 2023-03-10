/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

ListPage {
	id: root

	property string bindPrefix

	listView: GradientListView {
		model: ObjectModel {

			ListTextItem {
				//% "Model name"
				text: qsTrId("settings_vecan_model_name")
				dataSource: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				//% "Custom name"
				text: qsTrId("settings_vecan_custom_name")
				dataSource: root.bindPrefix + "/CustomName"
			}

			ListLabel {
				//% "Careful, for ESS systems, as well as systems with a managed battery, the CAN-bus device instance must remain configured to 0. See GX manual for more information."
				text: qsTrId("settings_vecan_instance_zero_warning")
			}

			ListSpinBox {
				//% "Device Instance"
				text: qsTrId("settings_vecan_device_instance")
				dataSource: root.bindPrefix + "/DeviceInstance"
			}

			ListTextItem {
				//% "Manufacturer"
				text: qsTrId("settings_vecan_manufacturer")
				dataSource: root.bindPrefix + "/Manufacturer"
			}

			ListTextItem {
				//% "Network Address"
				text: qsTrId("settings_vecan_nad")
				dataSource: root.bindPrefix + "/Nad"
			}

			ListTextItem {
				//% "Firmware Version"
				text: qsTrId("settings_vecan_firmware_version")
				dataSource: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				//% "Serial Number"
				text: qsTrId("settings_vecan_serial")
				dataSource: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				//% "Unique Identity Number"
				text: qsTrId("settings_vecan_uid")
				dataSource: root.bindPrefix + "/N2kUniqueNumber"
			}
		}
	}
}
