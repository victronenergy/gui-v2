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
				text: CommonWords.model_name
				dataSource: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				text: CommonWords.custom_name
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
				text: CommonWords.manufacturer
				dataSource: root.bindPrefix + "/Manufacturer"
			}

			ListTextItem {
				//% "Network Address"
				text: qsTrId("settings_vecan_nad")
				dataSource: root.bindPrefix + "/Nad"
			}

			ListFirmwareVersionItem {
				dataSource: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataSource: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				text: CommonWords.unique_identity_number
				dataSource: root.bindPrefix + "/N2kUniqueNumber"
			}
		}
	}
}
