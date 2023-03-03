/*
** Copyright (C) 2022 Victron Energy B.V.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property string bindPrefix

	GradientListView {
		model: ObjectModel {

			ListTextItem {
				//% "Model name"
				text: qsTrId("settings_vecan_model_name")
				source: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				//% "Custom name"
				text: qsTrId("settings_vecan_custom_name")
				source: root.bindPrefix + "/CustomName"
			}

			ListLabel {
				//% "Careful, for ESS systems, as well as systems with a managed battery, the CAN-bus device instance must remain configured to 0. See GX manual for more information."
				text: qsTrId("settings_vecan_instance_zero_warning")
			}

			ListSpinBox {
				//% "Device Instance"
				text: qsTrId("settings_vecan_device_instance")
				source: root.bindPrefix + "/DeviceInstance"
			}

			ListTextItem {
				//% "Manufacturer"
				text: qsTrId("settings_vecan_manufacturer")
				source: root.bindPrefix + "/Manufacturer"
			}

			ListTextItem {
				//% "Network Address"
				text: qsTrId("settings_vecan_nad")
				source: root.bindPrefix + "/Nad"
			}

			ListTextItem {
				//% "Firmware Version"
				text: qsTrId("settings_vecan_firmware_version")
				source: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				//% "Serial Number"
				text: qsTrId("settings_vecan_serial")
				source: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				//% "Unique Identity Number"
				text: qsTrId("settings_vecan_uid")
				source: root.bindPrefix + "/N2kUniqueNumber"
			}
		}
	}
}
