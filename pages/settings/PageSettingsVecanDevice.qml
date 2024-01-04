/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
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
				dataItem.uid: root.bindPrefix + "/ModelName"
			}

			ListTextItem {
				text: CommonWords.custom_name
				dataItem.uid: root.bindPrefix + "/CustomName"
			}

			ListLabel {
				//% "Careful, for ESS systems, as well as systems with a managed battery, the CAN-bus device instance must remain configured to 0. See GX manual for more information."
				text: qsTrId("settings_vecan_instance_zero_warning")
			}

			ListSpinBox {
				//% "Device Instance"
				text: qsTrId("settings_vecan_device_instance")
				dataItem.uid: root.bindPrefix + "/DeviceInstance"
			}

			ListTextItem {
				text: CommonWords.manufacturer
				dataItem.uid: root.bindPrefix + "/Manufacturer"
			}

			ListTextItem {
				//% "Network Address"
				text: qsTrId("settings_vecan_nad")
				dataItem.uid: root.bindPrefix + "/Nad"
			}

			ListFirmwareVersionItem {
				dataItem.uid: root.bindPrefix + "/FirmwareVersion"
			}

			ListTextItem {
				text: CommonWords.serial_number
				dataItem.uid: root.bindPrefix + "/Serial"
			}

			ListTextItem {
				text: CommonWords.unique_identity_number
				dataItem.uid: root.bindPrefix + "/N2kUniqueNumber"
			}
		}
	}
}
